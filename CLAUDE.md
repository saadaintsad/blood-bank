# Reddify (Blood Bank app)

## Project context

"Blood Bank" (on-screen name **Reddify**, tagline "Every drop finds its way.") is a mobile app for a university mobile app course. It connects people who urgently need blood with voluntary donors nearby. It is modelled on Bangladesh's government blood bank website (bloodbank.org.bd) and similar blood donation apps, so it should feel close to existing apps.

**Target users:** blood seekers (patients and families), voluntary donors (students and young adults), and general users.

**Planned features (built in stages):** sign up/login, donor registration, search donors by blood group/location/name, donor details with call/SMS, blood requests with status tracking, donation history, availability toggle, dashboard, profile, blood bank directory, health tips, push notifications.

**Tech stack:** Flutter and Dart. Later: Supabase (database + auth) and Firebase Cloud Messaging.

**Current stage: FIRST STAGE.** UI only with mock data, no backend. Screens are built one at a time and don't need to be connected. The owner tests in Chrome (`flutter run -d chrome`) and screenshots each screen, and will study and edit this code, so keep it clean and readable.

`docs/inspiration.pdf` holds screens from another blood donation app. Use it for inspiration only. Don't copy it; improve on it. Use the impeccable skill for design direction.

## Rules

- **Structure inside `lib/`:**
  - `main.dart`, `app.dart`
  - `theme/`: `app_colors.dart`, `app_text_styles.dart`, `app_theme.dart`
  - `models/`
  - `data/` (mock data)
  - `screens/` with subfolders `home/`, `auth/`, `donors/` (one file per screen)
  - `widgets/` (reusable widgets)
  - `utils/`: `constants.dart`, `validators.dart`
- One screen per file. No big widgets, models or mock data inside screen files. Extract reusable widgets into `widgets/`. Keep every file under about 250 lines.
- Material 3 and `google_fonts`. **No other packages without telling the user first.**
- Beginner-readable code: clear names, short comments explaining *why*, `const` constructors, nothing clever.
- Design: deep warm crimson primary (not pure red), soft off-white background, rounded cards, generous spacing, clear blood-group badges, 48dp touch targets, accessible contrast. Polished, not a generic template.
- Screens must look good at mobile width in Chrome. Never use network images; use icons, illustrations built from Flutter widgets, and initial-letter avatars.
- After each task: run `flutter analyze`, fix issues, then give the user a short walkthrough of the new files and the main Flutter concepts used.

## Design direction (chosen: "Donor Card Stamp")

The design idea comes from the printed donor cards that campus blood clubs hand out: **the blood group is a stamp, not a pill.**

- Colours: use `AppColors` / the theme only, never raw hex in screens. Crimson `#A3122A` for primary actions and stamps, card-stock background `#F4F1EC`, card surface `#FFFDF9` with a 1px warm border, slate ink `#1E2326` for text and the single FAB, green only for "available".
- Type: Archivo via `AppTextStyles`; pick Material roles from `Theme.of(context).textTheme`, don't hand-pick sizes.
- Blood group: always `BloodGroupBadge`, in the same fixed-size square at the start of a row. Use the large tilted stamp once per screen at most.
- States never rely on red alone: pair colour with an icon or word.
- Crimson app bar; standard Material controls (NavigationBar, FAB, chips, snackbars).
- Full direction: `.impeccable/surfaces/lib.md`. Product facts: `PRODUCT.md`.

## Commands

```sh
flutter run -d chrome   # run in Chrome (shown in a 430px phone frame)
flutter analyze         # must be clean after every task
flutter test            # validator and constants tests
```
