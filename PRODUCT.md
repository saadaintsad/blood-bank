# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users
- **Blood seekers**: patients and their families who need blood urgently, often under stress, searching on a phone from a hospital.
- **Voluntary donors**: mostly students and young adults in Bangladesh who register, keep their availability current, and answer calls or SMS from seekers.
- **General users**: people browsing open requests and, later, blood bank directories and health information.

One account type for everyone; becoming a donor adds a donor profile to the same account.

## Product Purpose
Reddify connects people who urgently need blood with voluntary donors in their district. Success means a seeker can find a matching, available donor by blood group and district and contact them within minutes.

## Positioning
Modelled on Bangladesh's government blood bank website (bloodbank.org.bd) and familiar local blood donation apps, so it should feel close to apps users already know while being clearer and more polished.

## Operating Context
- University mobile app course project, built in stages.
- Current phase: UI only with mock data behind repository interfaces, Provider for state. No Supabase, Firebase or network calls yet.
- Previewed in Chrome (`flutter run -d chrome`) inside a 430 px phone frame and screenshotted per screen; the target is Android phones, including small 360 dp screens.
- Later: Supabase (auth, database, RLS, database functions) and Firebase Cloud Messaging.

## Capabilities and Constraints
- Version 1 scope and every product rule live in `docs/requirements.md`; end-to-end behaviour in `docs/walkthrough.md`. Those files win over this summary.
- Version 1 covers accounts, donor profiles, donor search, blood requests, the "I'm Interested" flow, notifications and the dashboard. Hospital directory, information screens and reporting come later; forgot password is not in version 1.
- Login: Bangladeshi mobile number (01XXXXXXXXX) + password.
- Donor status: Green = Available, Yellow = Recently donated ("Available in X days"), Red = Not available (set by the donor). Always shown with a text label.
- Phone numbers are only visible to users with an open blood request, and only for Green or Yellow donors.
- Geography: the 64 districts of Bangladesh, then area within a district.
- Stack: Flutter + Dart, Material 3, google_fonts, Provider. No other packages without the user's approval.
- Language: English only for now.
- No network images. Visuals come from icons, widget-built illustrations, and initial-letter avatars.

## Brand Commitments
- Name: **Reddify**. Tagline proposed by Claude, open to change: "Every drop finds its way."

## Evidence on Hand
- `docs/requirements.md`, `docs/walkthrough.md`: the product rules.
- `docs/inspiration.pdf`: screens from another blood donation app, inspiration only, not to be copied.
- No real donors, statistics, testimonials, or partner hospitals. Mock data must read as clearly fictional sample data, and no fabricated impact figures.

## Product Principles
1. Urgency first: a seeker in a hospital corridor reaches a donor's phone number in as few taps as possible.
2. Blood group is the primary key: it is always visible and legible at a glance.
3. Familiar over novel: patterns users know from local blood apps and Android.
4. Privacy by rule: contact details appear only when the requirements allow it.
5. Readable code is part of the product: the student owner studies and edits every file.

## Accessibility & Inclusion
- 48dp minimum touch targets; WCAG AA contrast for text; works at 360 dp width.
- Never rely on colour alone for state (Green/Yellow/Red, request status); red also clashes with the crimson brand, so always pair with a label.
