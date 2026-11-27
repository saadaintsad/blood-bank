# Reddify – project guide for Claude Code

## What this is
Reddify (tagline "Every drop finds its way.") is a Flutter (Dart) Android app that connects blood seekers with voluntary donors in Bangladesh. It is a university mobile app course project. It is modelled on Bangladesh's government blood bank website (bloodbank.org.bd) and similar local blood donation apps, so it should feel close to apps people already know, only clearer and more polished.

- Full rules: `docs/requirements.md`. How the app behaves end to end: `docs/walkthrough.md`.
  Read both before building any screen. If a screen needs a rule that isn't in them, ask me; don't invent one.
- Product record for the impeccable skill: `PRODUCT.md`.
- Target users: blood seekers (patients and families), voluntary donors (students and young adults), general users.
- On-screen name is always `AppStrings.appName` ("Reddify"). Never hardcode "Blood Bank" in the UI.

## Current phase: UI only
- Build the frontend with mock data. No Supabase, Firebase or real network calls yet (Supabase auth/database and Firebase Cloud Messaging come later).
- All data comes from `lib/data/mock/` through repository interfaces in `lib/data/repositories/`,
  so the Supabase versions can replace the mocks later without touching screens.
- State management: Provider (approved in this file, but tell me when you add it to `pubspec.yaml`).
- Mock data must read as clearly fictional sample data. No invented statistics, testimonials or partner hospitals.
- I preview in Chrome (`flutter run -d chrome`): `PhoneFrame` shows the app 430 px wide on wide screens. I take a screenshot of each screen.

## Folder structure (keep to this)
```
lib/
  main.dart
  app.dart                  # MaterialApp, theme, routes
  theme/                    # colors.dart, text_styles.dart, spacing.dart, app_theme.dart
  models/                   # user.dart, donor.dart, blood_request.dart, donation.dart, enums.dart
  data/
    repositories/           # abstract interfaces
    mock/                   # mock implementations + sample data
  providers/                # ChangeNotifier classes
  screens/
    auth/                   # login, seeker_signup, donor_registration/
    home/
    dashboard/
    search/
    requests/
    donor/
    profile/
  widgets/                  # shared widgets: buttons, donor_card, status_chip, blood_group_badge, ...
  utils/                    # validators (BD phone 01XXXXXXXXX), blood compatibility, eligibility dates
```
- One screen per file. One public widget per file in `widgets/`. A screen's private sub-widgets may live in `screens/<area>/widgets/`.
- No big widgets, models or mock data inside screen files; screen files are for layout.
- No file over ~300 lines; split into widgets instead.

## Design rules
- Use only colors, text styles and spacing from `lib/theme/`. No hard-coded colors or font sizes in screens.
- Status colors: Green = Available, Yellow = Recently donated, Red = Not available. Always show a text label too,
  never color alone. The status red must look clearly different from the brand crimson.
- Primary action on a screen is a full-width red button; secondary actions are outlined.
- Every list screen needs empty, loading and error states.
- Minimum tap target 48 dp. Support small Android screens (360 dp wide); check 360 and 390 widths.
- Material 3 components (NavigationBar, chips, snackbars, dialogs) themed through `app_theme.dart`.
- Never use network images. Use icons, illustrations built from Flutter widgets, and initial-letter avatars.

### Design direction: "Donor Card Stamp" (chosen with the impeccable skill)
The look comes from the printed donor cards that campus blood clubs hand out: **the blood group is a stamp, not a pill.**
- Crimson `#A3122A` for primary actions, stamps and the app bar / top band. Card-stock background `#F4F1EC`. Card surface `#FFFDF9` with a 1 px warm border (`#E5DED5`). Slate ink `#1E2326` for text.
- Type: Archivo via google_fonts. Pick Material roles from `Theme.of(context).textTheme`; don't hand-pick sizes.
- Blood group: always `BloodGroupBadge`, in the same fixed-size square at the start of a row. Use the large tilted stamp at most once per screen.
- Signature layout: a crimson band at the top with one `RaisedCard` overlapping its bottom edge (Home hero, Login).
- Generous spacing, rounded cards, WCAG AA contrast.
- Use `docs/inspiration.pdf` for inspiration only. Don't copy it; improve on it.
- Status: `StatusChip` with `DonorStatus` (`models/enums.dart`) and the `AppColors.status…` tokens. The status red is a bright scarlet, never the brand crimson.
- Full direction contract: `.impeccable/surfaces/lib.md`. Where it conflicts with this file, this file wins.
- Use the impeccable skill for design work. Its final review and DESIGN.md are still pending.

## Working rules
- Before a new feature, show me a short plan (screens, widgets, files) and wait for my OK.
- **After every task, run `flutter analyze` and `flutter test` and fix all errors before reporting done.**
- Then give me a short walkthrough of the new files and the main Flutter concepts used.
- New logic in `utils/`, `providers/` or `data/` gets unit tests in `test/` (same folder layout).
- Explain any Flutter concept I might not know in a short comment or in your reply. I'm learning Flutter.
- Beginner-readable code: clear names, short comments explaining *why*, `const` constructors, nothing clever.
- Don't add packages without asking. Currently in use: google_fonts, provider.

## Conventions already in the code
- `utils/constants.dart` holds app strings (`AppStrings`), placeholder footer contact details (`AppContact`), `bloodGroups` and `bangladeshDistricts`. Spacing, radius and sizes live in `theme/spacing.dart`.
- Phone numbers: users may type `01…`, `+8801…` or `8801…`; `normalizeBangladeshiPhone()` (`utils/phone_number.dart`) turns them into the stored `01XXXXXXXXX`. Always normalize before saving or sending.
- Fixed screen copy (not data) may live next to its screen, e.g. `screens/home/home_content.dart`. Anything that will come from Supabase goes through `data/repositories/`.
- Mock login accepts only the sample accounts in `data/mock/sample_users.dart` (`01700000001` or `01700000002`, password `demo1234`).
- `app.dart` shows one screen as `home:` until routes are added.

## Next tasks (agreed, not started)
- Home screen to match requirements.md (logged out: Find Blood, Register as Donor, "Already have an account? Log in" link).
- Routes in `app.dart`.

## Commands
```sh
flutter run -d chrome   # preview in Chrome (430 px phone frame)
flutter analyze         # must pass after every task
flutter test            # must pass after every task
```
