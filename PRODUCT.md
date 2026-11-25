# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users
- **Blood seekers**: patients and their families who need blood urgently, often under stress, searching on a phone from a hospital.
- **Voluntary donors**: mostly students and young adults in Bangladesh who register, keep their availability current, and answer calls or SMS from seekers.
- **General users**: people browsing blood bank directories, health tips, and open requests.

## Product Purpose
Reddify connects people who urgently need blood with voluntary donors nearby. Success means a seeker can find a matching, available donor by blood group and district and contact them within minutes.

## Positioning
Modelled on Bangladesh's government blood bank website (bloodbank.org.bd) and familiar local blood donation apps, so it should feel close to apps users already know while being clearer and more polished.

## Operating Context
- University mobile app course project, built in stages.
- Stage 1 (current): UI only with mock data, no backend. Screens are built one at a time and need not be connected. Tested in Chrome (`flutter run -d chrome`) at phone width and screenshotted per screen.
- Later stages: Supabase (database + auth) and Firebase Cloud Messaging.

## Capabilities and Constraints
- Planned features: sign up/login, donor registration, donor search by blood group / location / name, donor details with call/SMS, blood requests with status tracking, donation history, availability toggle, dashboard, profile, blood bank directory, health tips, push notifications.
- Stack: Flutter + Dart, Material 3, google_fonts. No other packages without the user's approval.
- Geography: the 64 districts of Bangladesh; phone numbers in Bangladeshi +880 format.
- Language: English only for now.
- No network images. Visuals come from icons, widget-built illustrations, and initial-letter avatars.

## Brand Commitments
- Name: **Reddify**. Tagline proposed by Claude, open to change: "Every drop finds its way."

## Evidence on Hand
- `docs/inspiration.pdf`: screens from another blood donation app, inspiration only, not to be copied.
- No real donors, statistics, testimonials, or partner hospitals. Mock data must read as clearly fictional sample data, and no fabricated impact figures.

## Product Principles
1. Urgency first: a seeker in a hospital corridor reaches a donor's phone number in as few taps as possible.
2. Blood group is the primary key: it is always visible and legible at a glance.
3. Familiar over novel: patterns users know from local blood apps and their OS.
4. Readable code is part of the product: the student owner studies and edits every file.

## Accessibility & Inclusion
- 48dp minimum touch targets; WCAG AA contrast for text.
- Do not rely on red alone to convey state (availability, status) since red is the brand color.
