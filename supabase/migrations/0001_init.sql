-- Beauty HuB MVP schema
-- Salons, styles, services, bookings, reviews, favourites.
-- See docs/consumer-flow.md for the product spec this implements.

create extension if not exists pgcrypto;
create extension if not exists postgis;

-- ---------------------------------------------------------------------------
-- profiles (one row per auth.users, created via trigger on signup)
-- ---------------------------------------------------------------------------
create table profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  full_name text,
  phone text unique,
  avatar_url text,
  created_at timestamptz not null default now()
);

create function handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into profiles (id, phone)
  values (new.id, new.phone);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function handle_new_user();

-- ---------------------------------------------------------------------------
-- categories (fixed chip list: Braids, Installs/Weaves, Nails, Lashes, Makeup, Barber)
-- ---------------------------------------------------------------------------
create table categories (
  slug text primary key,
  label text not null,
  sort_order int not null default 0
);

-- ---------------------------------------------------------------------------
-- styles (master catalog shown in the style feed, e.g. "Knotless box braids, mid-back")
-- ---------------------------------------------------------------------------
create table styles (
  id uuid primary key default gen_random_uuid(),
  category_slug text not null references categories (slug),
  name text not null,
  description text,
  cover_photo_url text,
  created_at timestamptz not null default now()
);

create index styles_category_idx on styles (category_slug);

-- ---------------------------------------------------------------------------
-- salons (seeded "public listing" rows are unclaimed until owner_id is set)
-- ---------------------------------------------------------------------------
create table salons (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid references auth.users (id),
  name text not null,
  is_claimed boolean not null default false,
  is_verified boolean not null default false,
  is_mobile boolean not null default false,
  phone text,
  whatsapp text,
  address_line text,
  suburb text not null,
  city text not null default 'Johannesburg',
  location geography(point, 4326) not null,
  operating_hours jsonb,
  avg_response_minutes int,
  rating_avg numeric(2, 1) not null default 0,
  rating_count int not null default 0,
  created_at timestamptz not null default now()
);

create index salons_location_idx on salons using gist (location);
create index salons_suburb_idx on salons (suburb);

-- ---------------------------------------------------------------------------
-- salon_services (a salon's price/duration for a given style)
-- ---------------------------------------------------------------------------
create table salon_services (
  id uuid primary key default gen_random_uuid(),
  salon_id uuid not null references salons (id) on delete cascade,
  style_id uuid not null references styles (id),
  price_cents int not null,
  hair_included boolean not null default false,
  hair_included_price_delta_cents int not null default 0,
  duration_minutes int not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create index salon_services_salon_idx on salon_services (salon_id);
create index salon_services_style_idx on salon_services (style_id);

-- ---------------------------------------------------------------------------
-- salon_photos (portfolio gallery; hero photos surface in the style feed)
-- ---------------------------------------------------------------------------
create table salon_photos (
  id uuid primary key default gen_random_uuid(),
  salon_id uuid not null references salons (id) on delete cascade,
  style_id uuid references styles (id),
  photo_url text not null,
  is_hero boolean not null default false,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create index salon_photos_salon_idx on salon_photos (salon_id);

-- ---------------------------------------------------------------------------
-- bookings (requests, not confirmed slots -- salon accepts/declines out of band)
-- ---------------------------------------------------------------------------
create table bookings (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid not null references auth.users (id),
  salon_id uuid not null references salons (id),
  salon_service_id uuid not null references salon_services (id),
  status text not null default 'pending'
    check (status in ('pending', 'confirmed', 'declined', 'cancelled', 'completed')),
  location_type text not null default 'at_salon'
    check (location_type in ('at_salon', 'at_customer')),
  customer_address text,
  requested_date date not null,
  requested_time_slot time not null,
  service_price_cents int not null,
  hair_included boolean not null default false,
  travel_fee_cents int not null default 0,
  total_price_cents int not null,
  deposit_percent numeric not null default 0.25,
  deposit_amount_cents int not null,
  deposit_paid boolean not null default false,
  deposit_paid_at timestamptz,
  paystack_reference text,
  cancellation_deadline timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index bookings_customer_idx on bookings (customer_id);
create index bookings_salon_idx on bookings (salon_id);
create index bookings_status_idx on bookings (status);

create function set_booking_defaults()
returns trigger
language plpgsql
as $$
begin
  new.cancellation_deadline :=
    (new.requested_date + new.requested_time_slot) - interval '48 hours';
  new.updated_at := now();
  return new;
end;
$$;

create trigger bookings_set_defaults
  before insert or update on bookings
  for each row execute function set_booking_defaults();

-- ---------------------------------------------------------------------------
-- reviews (one per completed booking; only the booking's customer may write it)
-- ---------------------------------------------------------------------------
create table reviews (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references bookings (id),
  customer_id uuid not null references auth.users (id),
  salon_id uuid not null references salons (id),
  rating smallint not null check (rating between 1 and 5),
  body text,
  photo_urls text[] not null default '{}',
  created_at timestamptz not null default now()
);

create index reviews_salon_idx on reviews (salon_id);

-- security definer: a customer inserting a review only has RLS-scoped
-- read/write on salons (public read + owner-only write), but rating
-- refresh must always be allowed regardless of who triggered it.
create function refresh_salon_rating()
returns trigger
language plpgsql
security definer set search_path = public
as $$
declare
  target_salon_id uuid := coalesce(new.salon_id, old.salon_id);
begin
  update salons
  set
    rating_avg = coalesce((select round(avg(rating), 1) from reviews where salon_id = target_salon_id), 0),
    rating_count = (select count(*) from reviews where salon_id = target_salon_id)
  where id = target_salon_id;
  return null;
end;
$$;

create trigger reviews_refresh_salon_rating
  after insert or update or delete on reviews
  for each row execute function refresh_salon_rating();

-- ---------------------------------------------------------------------------
-- favourites
-- ---------------------------------------------------------------------------
create table favourites (
  user_id uuid not null references auth.users (id) on delete cascade,
  salon_id uuid not null references salons (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, salon_id)
);

-- ---------------------------------------------------------------------------
-- nearby_salons RPC -- powers "salons within N km" for the style feed / map view
-- ---------------------------------------------------------------------------
create function nearby_salons(
  lat double precision,
  lng double precision,
  radius_km double precision default 5,
  filter_category text default null
)
returns table (
  salon_id uuid,
  name text,
  suburb text,
  is_mobile boolean,
  is_verified boolean,
  rating_avg numeric,
  rating_count int,
  distance_km double precision
)
language sql
stable
as $$
  select
    s.id,
    s.name,
    s.suburb,
    s.is_mobile,
    s.is_verified,
    s.rating_avg,
    s.rating_count,
    st_distance(s.location, st_makepoint(lng, lat)::geography) / 1000.0 as distance_km
  from salons s
  where st_dwithin(s.location, st_makepoint(lng, lat)::geography, radius_km * 1000)
    and (
      filter_category is null
      or exists (
        select 1
        from salon_services ss
        join styles st on st.id = ss.style_id
        where ss.salon_id = s.id
          and ss.is_active
          and st.category_slug = filter_category
      )
    )
  order by distance_km asc;
$$;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------
alter table profiles enable row level security;
alter table categories enable row level security;
alter table styles enable row level security;
alter table salons enable row level security;
alter table salon_services enable row level security;
alter table salon_photos enable row level security;
alter table bookings enable row level security;
alter table reviews enable row level security;
alter table favourites enable row level security;

-- profiles: a user can only see/update their own row
create policy "profiles_select_own" on profiles
  for select using (auth.uid() = id);
create policy "profiles_update_own" on profiles
  for update using (auth.uid() = id);

-- categories, styles, salons, salon_services, salon_photos: public read
-- (anonymous browsing is the whole point of the discovery flow)
create policy "categories_public_read" on categories
  for select using (true);
create policy "styles_public_read" on styles
  for select using (true);
create policy "salons_public_read" on salons
  for select using (true);
create policy "salon_services_public_read" on salon_services
  for select using (true);
create policy "salon_photos_public_read" on salon_photos
  for select using (true);

-- salons: a claimed owner can manage their own listing
create policy "salons_owner_write" on salons
  for update using (auth.uid() = owner_id);
create policy "salon_services_owner_write" on salon_services
  for all using (auth.uid() = (select owner_id from salons where id = salon_id));
create policy "salon_photos_owner_write" on salon_photos
  for all using (auth.uid() = (select owner_id from salons where id = salon_id));

-- bookings: a customer can only see/create/update their own booking requests
create policy "bookings_select_own" on bookings
  for select using (auth.uid() = customer_id);
create policy "bookings_insert_own" on bookings
  for insert with check (auth.uid() = customer_id);
create policy "bookings_update_own" on bookings
  for update using (auth.uid() = customer_id);

-- reviews: public read; a customer may only review their own completed booking
create policy "reviews_public_read" on reviews
  for select using (true);
create policy "reviews_insert_own_completed_booking" on reviews
  for insert with check (
    auth.uid() = customer_id
    and exists (
      select 1 from bookings b
      where b.id = booking_id
        and b.customer_id = auth.uid()
        and b.status = 'completed'
    )
  );

-- favourites: a user can only see/manage their own saved salons
create policy "favourites_all_own" on favourites
  for all using (auth.uid() = user_id);
