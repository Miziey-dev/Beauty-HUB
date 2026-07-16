# Beauty HuB

Discovery + booking app for beauty/hair/nail/lash/barber services. Consumers
browse a style feed anonymously and only sign up when they book; salons
accept/decline booking requests and get paid a deposit up front.

See [`docs/consumer-flow.md`](docs/consumer-flow.md) for the full MVP v1
product spec (screen-by-screen flow, stack decisions, build order).

CI (`.github/workflows/`) runs `flutter analyze` + `flutter test` on every
`app/` change, and applies the Supabase migrations + seed against a real
Postgres+PostGIS service container on every `supabase/` change (also
checking `seed.sql` hasn't drifted from `generate_seed.py`).

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
  migrations/0003_profile_extras.sql
                               saved addresses + notification prefs on profiles
  seed.sql                    generated demo data: 36 salons around
                               Braamfontein/Johannesburg
  config.toml                 local Supabase CLI config
scripts/
  generate_seed.py            regenerates supabase/seed.sql deterministically
docs/
  consumer-flow.md            product spec this schema implements
app/                          Flutter app (all 8 screens from the spec)
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

## Flutter app

`app/` is a Flutter project covering the full consumer flow from
`docs/consumer-flow.md`: location permission, Style Feed, Style Results
(list/map), Salon Profile, phone-OTP/Google auth, the booking request flow
(service options → date/time → deposit & confirm), My Bookings, leaving a
review, and Profile/Settings. Navigation between the top-level screens
(Discover / Bookings / Profile) is a bottom nav shell
(`lib/features/shell/main_shell.dart`) added to make Screens 2, 6, and 8
reachable -- it isn't itself one of the spec's numbered screens.

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
against fakes shaped like the real Supabase schema:

```bash
flutter analyze
flutter test
```

### Deliberately stubbed, pending real credentials/infra

Everything below is real, working code behind an interface (same pattern
throughout: a `data/*_data_source.dart` + a fake used in tests) -- each just
needs one piece of external setup before it does something for real:

| Feature | Where | What's needed |
| --- | --- | --- |
| Map view (Screen 3) | `features/style_results/widgets/map_placeholder.dart` | Plots real salon coordinates in a lightweight in-app scatter view instead of a real map; swap for a `google_maps_flutter` widget once a Maps API key is configured. |
| Paystack deposit (Screen 5c) | `data/payment_gateway.dart` | `StubPaystackGateway` simulates a successful charge; swap for a real Paystack checkout once a public key exists. |
| Review photo storage (Screen 7) | `data/photo_upload_service.dart` | Uploads to a Supabase Storage bucket named `review-photos`, which needs creating (public read, authenticated write) via the dashboard or CLI -- not something a SQL migration creates. |
| Google sign-in (Screen 5b) | `data/auth_data_source.dart` | Needs a custom URL scheme (`io.beautyhub.app://login-callback`) registered natively (AndroidManifest intent-filter / iOS URL type) for the OAuth redirect to return to the app. Phone OTP works as soon as Supabase Auth's SMS provider is configured. |
| Push notifications | not yet built | Firebase Cloud Messaging setup (Screen 7's "how was your appointment" prompt, booking confirmations). Not started even behind a stub: `firebase_core`'s native Gradle plugin needs a real `google-services.json` just to build, unlike everything else above which is a pure Dart-level interface -- wiring it in without a real Firebase project would break `flutter build` for everyone else. |

All UI copy lives in `lib/l10n/strings.dart` (a single `Strings` class) per
the spec's cross-cutting rule -- "keep all strings in one localisation file
so isiZulu etc. is a config job later." It's plain Dart constants, not
Flutter's `gen-l10n`/ARB tooling, since actual locale-switching isn't
needed yet -- swapping to that later just means running `flutter gen-l10n`
against the strings already collected here as the source of truth.

## Build order (docs/consumer-flow.md) -- status

1. ✅ Supabase schema + seed data
2. ✅ Style Feed → Style Results → Salon Profile (read-only, demo-able to salons)
3. ✅ Auth (phone OTP + Google) + booking request flow (5a-5b)
4. ✅ Deposit & confirm (5c, Paystack stubbed) + My Bookings
5. ✅ Reviews (photo upload stubbed) -- push notifications still to do
