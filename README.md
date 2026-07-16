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
  migrations/0001_init.sql    schema: categories, styles, salons, services,
                               photos, bookings, reviews, favourites + RLS
  migrations/0002_discovery_rpcs.sql
                               style_feed / style_results RPCs for the
                               discovery screens (PostGIS "within N km")
  seed.sql                    generated demo data: 36 salons around
                               Braamfontein/Johannesburg
  config.toml                 local Supabase CLI config
scripts/
  generate_seed.py            regenerates supabase/seed.sql deterministically
docs/
  consumer-flow.md            product spec this schema implements
app/                          Flutter app (Screens 1-4: location, style feed,
                               style results, salon profile)
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

## Flutter app (build order step 2)

`app/` is a standard Flutter project covering Screens 1-4 from
`docs/consumer-flow.md`: location permission, Style Feed, Style Results
(list/map), and Salon Profile -- anonymous, read-only browsing wired to the
Supabase schema above. Booking (Screen 5+) is deliberately not built yet;
tapping Book shows a "coming in the next milestone" message.

Supabase config is passed via `--dart-define` (not bundled as an asset, so
no secrets ever land in the repo or the compiled app by accident):

```bash
cd app
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://your-project-ref.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Without real credentials the app still builds and analyzes, but network
calls will fail -- run the test suite instead, which exercises every screen
against fake Supabase responses shaped like the real schema:

```bash
flutter analyze
flutter test
```

Map view (Screen 3's list/map toggle) currently plots real salon
coordinates in a lightweight in-app scatter view rather than a real
Google Map, since that needs a Maps API key; swap
`lib/features/style_results/widgets/map_placeholder.dart` for a
`google_maps_flutter` widget once one is configured.

## Next steps

Per the build order in `docs/consumer-flow.md`:

1. ✅ Supabase schema + seed data
2. ✅ Flutter app: Style Feed → Style Results → Salon Profile (read-only,
   demo-able to salons)
3. Auth (phone OTP + Google) + booking request flow
4. Paystack deposits + My Bookings
5. Reviews + push notifications
