# Beauty HuB — Consumer Flow (MVP v1)

Screen-by-screen user flow for the consumer discovery + booking side, plus the
recommended dev stack.

**Guiding principle:** let users browse everything anonymously; only ask them
to sign up at the moment of booking. Every sign-up wall before that kills
conversion.

## Recommended stack (decided)

| Layer | Choice | Why |
| --- | --- | --- |
| Mobile app | Flutter (Dart) | One codebase for Android + iOS. Dart's syntax is the closest of any cross-platform framework to Java, so ramp-up is days, not weeks. Excellent for image-heavy UIs (style feed, galleries). |
| Backend | Supabase (managed PostgreSQL + PostGIS, Auth, Storage, Edge Functions) | Auth (phone OTP + Google), a real Postgres DB with PostGIS for "salons within 5 km" queries, image storage with CDN, and row-level security — without building/hosting a backend for the MVP. It's still Postgres, so nothing is throwaway: if custom logic outgrows it, bolt a Spring Boot service onto the same database later. |
| Payments (deposits) | Paystack | Solid South African support (cards, EFT, Apple/Google Pay), clean API, split payments later for salon payouts. Yoco is the fallback if you want SA-native. |
| Maps & geocoding | Google Maps SDK + Places API | Map view, suburb autocomplete, geocoding salon addresses. |
| Push notifications | Firebase Cloud Messaging | Free, works fine alongside Supabase. Booking confirmations/reminders. |
| Images | Supabase Storage + on-the-fly transforms | Compress/resize portfolio photos; the feed must load fast on mobile data. |

Why not Java end-to-end: Android-only Java/Kotlin locks you out of iOS;
Spring Boot from day one means building auth, storage, image pipelines, and
hosting yourself before validating anything. Keep Java as your scaling card,
not your starting cost.

## Screen 0 — Splash / First launch

- Logo + tagline, auto-advances.
- First launch only: 2–3 swipeable intro cards ("Find your style → Book
  nearby → Pay a deposit, secure your slot"). Skippable.
- Next: Location permission.

## Screen 1 — Location permission

- Friendly explainer: "We use your location to find stylists near you."
- Primary: Use my location (GPS). Fallback: Enter your suburb (Places
  autocomplete).
- Store chosen location locally; changeable anytime via a location pill in
  the home header.
- Deny-path: app still works with manual suburb — never dead-end on a denied
  permission.
- Next: Home (Style Feed).

## Screen 2 — Home / Style Feed (the heart of the app)

- Header: location pill ("Braamfontein ▾") + search icon.
- Category chips (horizontal scroll): Braids · Installs/Weaves · Nails ·
  Lashes · Makeup · Barber.
- Below: 2-column masonry grid of style cards — photo, style name ("Knotless
  box braids, mid-back"), price-from ("from R650"), distance to nearest
  stylist offering it, small rating badge.
- Pull to refresh; infinite scroll.
- Tap a style card → Screen 3.
- Search: searches styles AND salon names ("knotless", "Zanele's Braids").
- Empty state (cold start): if no styles within radius, widen radius
  automatically and label results "a bit further out" — never show a blank
  screen.

## Screen 3 — Style results (list ⇄ map)

- Context header: chosen style photo + name.
- Filters row: distance, price range, rating, "Comes to you" (mobile
  stylists), "Hair included".
- Sort: Recommended (rating × distance blend) / Nearest / Cheapest / Top
  rated.
- List cards: salon name, hero photo of THEIR version of this style, price,
  duration ("±6 hrs"), rating (count), distance, badges (Verified, Mobile,
  Hair included).
- Toggle to map view: pins with price labels; tapping a pin shows a
  bottom-sheet mini card.
- Tap card → Screen 4.

## Screen 4 — Salon / Stylist profile

- Hero gallery (swipeable portfolio, filterable by category).
- Name, rating + review count, distance, address (or "Mobile — comes to
  you"), operating hours, "Responds in ~1 hr" indicator (later).
- Services list, grouped by category. Each row: style name, price, duration,
  hair-included flag, [Book] button.
- Reviews section: overall breakdown (5★ bars), individual reviews with
  photos ("photo reviews" ranked first — these sell the booking).
- Sticky bottom bar: Book now (opens service picker if none selected).
- Unclaimed seeded profiles show "Info from public listings — Own this
  salon? Claim it" instead of Book, with a WhatsApp/call button. (This is
  the salon-acquisition funnel.)
- Next: Booking flow.

## Screen 5 — Booking flow (3 steps, one screen each)

**5a — Service & options**

- Selected service, price, duration.
- Options: hair included vs bring-your-own (adjusts price), length/size
  variants if defined.
- Mobile stylists: toggle "At salon / At my place" → address input + travel
  fee shown.

**5b — Date & time**

- Calendar (next 30 days) + time-slot chips sized by service duration (a
  6-hr braid job only offers start times that fit before closing).
- MVP rule: slots are *requests*, not confirmed bookings. Copy: "Zanele
  confirms within 2 hours." (No live calendar sync in v1 — the salon
  accepts/declines from a simple link/WhatsApp message.)
- Auth gate lives here: to continue, sign in with phone number OTP (primary,
  low-friction in SA) or Google.

**5c — Deposit & confirm**

- Summary card: style photo, salon, date/time, address, price breakdown
  (service + hair + travel), deposit due now (e.g. 20–30%, salon-configurable;
  MVP: fixed 25%), balance due at appointment.
- Cancellation policy in plain language ("Free cancellation until 48 hrs
  before; after that the deposit is forfeited").
- Pay via Paystack sheet (card / EFT / Google Pay).
- Success screen: big checkmark, booking reference, add-to-calendar button,
  "You'll get a notification when Zanele confirms."

## Screen 6 — My Bookings

- Tabs: Upcoming / Past.
- Upcoming card: status chip (Awaiting confirmation → Confirmed → Declined
  w/ auto-refund), date/time, salon, deposit paid, [Get directions]
  [Reschedule] [Cancel].
- Declined or expired requests auto-refund the deposit and suggest 3 similar
  nearby stylists.
- Past card: [Book again] + [Leave a review].

## Screen 7 — Review flow (post-appointment)

- Push notification next morning: "How was your appointment at Zanele's?"
- 1–5 stars, optional text, photo upload strongly encouraged ("Show off the
  result") — photo reviews feed the style feed with real local content,
  which is the content flywheel.
- Only clients with a completed booking can review → trust.

## Screen 8 — Profile / Settings (thin for MVP)

- Name, phone, saved addresses, notification prefs, saved/favourited salons,
  help/contact, T&Cs.

## Cross-cutting rules

- Anonymous browsing everywhere; auth only at booking (5b) and reviewing.
- Every empty state has an action (widen radius, change category, suggest
  nearby styles).
- Images lazy-load, compressed; assume mobile data, mid-range Android.
- English UI for v1; keep all strings in one localisation file so isiZulu
  etc. is a config job later.

## Out of scope for v1 (deliberately)

- Live calendar availability / salon-side app (request-based booking
  instead)
- In-app chat (WhatsApp deep-link instead)
- Loyalty points, referrals, promos
- iOS release (build with Flutter so it's one flag later, ship Android first
  — SA market share)

## Build order suggestion

1. Supabase schema (salons, services, styles, bookings, reviews) + seed
   30–50 salons in one area
2. Screens 2 → 3 → 4 (discovery, read-only) — this alone is demo-able to
   salons
3. Auth + booking request flow (5a–5b, no payment yet)
4. Paystack deposits (5c) + My Bookings
5. Reviews + push notifications
