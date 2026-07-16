-- RPCs for the discovery screens (docs/consumer-flow.md, Screens 2-3):
-- style_feed powers the Home masonry grid, style_results powers the
-- filtered list/map view for a single chosen style.

create function style_feed(
  lat double precision,
  lng double precision,
  radius_km double precision default 5,
  filter_category text default null
)
returns table (
  style_id uuid,
  style_name text,
  category_slug text,
  cover_photo_url text,
  price_from_cents int,
  nearest_distance_km double precision,
  best_rating numeric
)
language sql
stable
as $$
  with nearby as (
    select
      st.id as style_id,
      st.name as style_name,
      st.category_slug,
      st.cover_photo_url,
      ss.price_cents,
      s.rating_avg,
      st_distance(s.location, st_makepoint(lng, lat)::geography) / 1000.0 as distance_km
    from salon_services ss
    join styles st on st.id = ss.style_id
    join salons s on s.id = ss.salon_id
    where ss.is_active
      and st_dwithin(s.location, st_makepoint(lng, lat)::geography, radius_km * 1000)
      and (filter_category is null or st.category_slug = filter_category)
  )
  select
    style_id,
    style_name,
    category_slug,
    cover_photo_url,
    min(price_cents) as price_from_cents,
    min(distance_km) as nearest_distance_km,
    max(rating_avg) as best_rating
  from nearby
  group by style_id, style_name, category_slug, cover_photo_url
  order by nearest_distance_km asc;
$$;

create function style_results(
  p_style_id uuid,
  lat double precision,
  lng double precision,
  radius_km double precision default 15,
  max_price_cents int default null,
  min_rating numeric default null,
  mobile_only boolean default false,
  hair_included_only boolean default false
)
returns table (
  salon_service_id uuid,
  salon_id uuid,
  salon_name text,
  hero_photo_url text,
  price_cents int,
  duration_minutes int,
  hair_included boolean,
  is_mobile boolean,
  is_verified boolean,
  rating_avg numeric,
  rating_count int,
  distance_km double precision,
  salon_lat double precision,
  salon_lng double precision
)
language sql
stable
as $$
  select
    ss.id as salon_service_id,
    s.id as salon_id,
    s.name as salon_name,
    (
      select sp.photo_url from salon_photos sp
      where sp.salon_id = s.id and sp.is_hero
      limit 1
    ) as hero_photo_url,
    ss.price_cents,
    ss.duration_minutes,
    ss.hair_included,
    s.is_mobile,
    s.is_verified,
    s.rating_avg,
    s.rating_count,
    st_distance(s.location, st_makepoint(lng, lat)::geography) / 1000.0 as distance_km,
    st_y(s.location::geometry) as salon_lat,
    st_x(s.location::geometry) as salon_lng
  from salon_services ss
  join salons s on s.id = ss.salon_id
  where ss.style_id = p_style_id
    and ss.is_active
    and st_dwithin(s.location, st_makepoint(lng, lat)::geography, radius_km * 1000)
    and (max_price_cents is null or ss.price_cents <= max_price_cents)
    and (min_rating is null or s.rating_avg >= min_rating)
    and (not mobile_only or s.is_mobile)
    and (not hair_included_only or ss.hair_included)
  order by distance_km asc;
$$;
