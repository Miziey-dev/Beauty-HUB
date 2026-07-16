# Beauty HuB

Discovery + booking app for beauty/hair/nail/lash/barber services. Consumers
browse a style feed anonymously and only sign up when they book; salons
accept/decline booking requests and get paid a deposit up front.

See [`docs/consumer-flow.md`](docs/consumer-flow.md) for the full MVP v1
product spec (screen-by-screen flow, stack decisions, build order).

## Stack

- **Mobile app:** Flutter (Dart) — Android first, iOS is a flag flip later.
- **Backend:** Supabase (Postgres + PostGIS, Auth, Storage, Edge Functions).
- **Payments:** Paystack (deposits).
- **Maps:** Google Maps SDK + Places API.
- **Push:** Firebase Cloud Messaging.

## Repo layout

```
supabase/
  migrations/0001_init.sql   schema: categories, styles, salons, services,
                              photos, bookings, reviews, favourites + RLS
  seed.sql                   generated demo data: 36 salons around
                              Braamfontein/Johannesburg
  config.toml                local Supabase CLI config
scripts/
  generate_seed.py           regenerates supabase/seed.sql deterministically
docs/
  consumer-flow.md           product spec this schema implements
```

## Database (build order step 1)

Requires the [Supabase CLI](https://supabase.com/docs/guides/cli).

```bash
supabase login
supabase link --project-ref <your-project-ref>
supabase db push        # applies supabase/migrations/0001_init.sql
psql "$(supabase db url)" -f supabase/seed.sql
```

To regenerate the seed data (edit `scripts/generate_seed.py`, e.g. to add
more salons or styles):

```bash
python3 scripts/generate_seed.py
```

Copy `.env.example` to `.env` and fill in your Supabase, Paystack, Google
Maps, and Firebase credentials — none of this repo's code should hardcode
real keys.

## Next steps

Per the build order in `docs/consumer-flow.md`:

1. ✅ Supabase schema + seed data
2. Flutter app: Style Feed → Style Results → Salon Profile (read-only,
   demo-able to salons)
3. Auth (phone OTP + Google) + booking request flow
4. Paystack deposits + My Bookings
5. Reviews + push notifications
