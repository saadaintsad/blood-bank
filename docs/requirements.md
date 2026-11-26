# Reddify – Requirements (Version 1)

Nov 25, 2026 · @Saad Islam

## Overview

Reddify version 1 is a Flutter + Supabase Android app that connects people who need blood with voluntary donors in their district. Version 1 covers accounts, donor profiles, donor search, blood requests, the "I'm Interested" flow, notifications and the dashboard. The hospital directory, information screens and reporting come later.

This list merges Requirements 08–09 and the "I'm Interested" flow from the earlier chat with the decisions made on 25 Nov 2026. Where they conflict, the later decision wins. Requirements 01–07 were not available when this was written; see the last section.

## Accounts and login

Everyone uses one account type; becoming a donor adds a donor profile to it.

- **Seeker sign-up:** a new user who taps Find Blood registers with name, mobile number and password only.
- **Seeker becomes a donor:** name and number are pre-filled; they enter only the donor details.
- **New donor:** enters all details in one form.
- **Donor who needs blood:** uses the same account, with no second sign-up.
- **Login:** mobile number + password. Implementation: store the number as an email such as `01712345678@reddify.app` and use Supabase email/password auth with email confirmation off.
- **Phone format:** validate Bangladeshi numbers, 01XXXXXXXXX.
- **Forgot password:** not in version 1.
- **Future:** SMS OTP verification of numbers.

## Home screen and dashboard

The home screen changes with login state, and one dashboard serves every user.

**Home screen, logged out**

- **Find Blood:** large primary red button.
- **Register as Donor:** outlined secondary button below it.
- **"Already have an account? Log in":** small link at the bottom.

**Home screen, logged in**

- Find Blood and Post Request.
- Register as Donor, shown only if the user is not yet a donor.

**Dashboard (all users)**

- Profile card.
- My Requests, with each request's status.
- Quick actions: Find Blood, Post Request.

**Dashboard, donors also see**

- Availability card: color, and "Available in X days" when Yellow.
- Total donations and last donation date.
- Any pending "Did you donate?" question.
- Shortcut to Open Requests in their district.

**Dashboard, non-donors also see**

- A "Become a Donor" card in place of the donor section.

## Donor registration and profile

Donor registration asks for the fields below; existing users skip name, number and password.

| Field | Required | Visible to others |
| --- | --- | --- |
| Name | Yes | All logged-in users |
| Mobile number | Yes (pre-filled for existing users) | Users with an open request |
| Password | New users only | No |
| Blood group | Yes | All logged-in users |
| Gender | Yes (sets donation gap) | All logged-in users |
| Date of birth | Yes, age 18–60 | No |
| District and area | Yes | All logged-in users |
| Extra location details | Optional | No (private) |
| GPS permission | Optional | No; only a distance range is shown |
| Last donation date | Optional ("Never donated" allowed) | No |
| Receive alerts ON/OFF | Yes, default ON | No |
| Consent | Yes, required to finish | — |

**Consent text:** "Your name, blood group, area and availability will be visible to Reddify users. Your phone number will be visible to users with an active blood request while you are Green or Yellow."

- The 18–60 age range is stored as a setting in Supabase. Confirm it with a Bangladeshi source.
- Users outside the range can still use the app as seekers.
- The "Show phone number" switch from Requirement 08 is removed. Donors who want a break set their status to Red.

## Availability and eligibility

Each donor has one of three statuses, and the newest donation date sets when Yellow ends.

| Status | Meaning | In search | Automatic alerts |
| --- | --- | --- | --- |
| Green | Available | Yes | Yes |
| Yellow | Recently donated | Yes, labelled "Available in X days" | No |
| Red | Not available (set by donor) | No | No |

- **Waiting period:** men 84 days (12 weeks), women 112 days (16 weeks), any other gender option 112 days. Values come from [NHS Blood and Transplant](https://www.blood.co.uk/who-can-give-blood) and are stored as settings in Supabase.
- **Yellow to Green:** automatic when the waiting period ends.
- **Red:** set and cleared manually by the donor.
- **Starting status:** Yellow if the last donation date at registration is within the waiting period, otherwise Green.
- **Recording a donation:** donors can add one manually with date (required, not in the future), hospital or place (optional) and a note (optional). A "Yes" in the "I'm Interested" flow also records one.
- **History:** every entry counts toward total donations and appears in the donation history.

## Location

Donors choose their area by hand, and GPS is an optional extra for distance.

- **Manual (required):** district, then area or neighbourhood, plus optional extra details.
- **GPS (optional):** the donor can allow location permission; the app works fully without it.
- **Privacy:** exact coordinates and extra details are never shown. Other users see only the area, and a distance range when GPS is available.
- **Distance:** straight-line distance, calculated in a Supabase database function so donor coordinates never reach other users' phones. No Google Maps API is needed.

## Finding donors

Any logged-in user can search donors, but phone numbers appear only while the user has an open blood request.

- **Filters:** blood group (required), district, area, name, and "only available" (Green only).
- **Who appears:** Green and Yellow donors. Red donors and donors in their 3-hour "I'm Interested" window are hidden.
- **Sorting:**
  1. Same area as the seeker's selected area.
  2. Rest of the same district.
  3. Within each group, Green before Yellow, then nearest first when both sides allowed GPS.
- **Result card:** name, blood group, area, gender, availability color, and a distance range such as "2–5 km" when available.
- **Without an open request:** search shows no phone numbers.
- **With an open request:** donor details show the phone number with Call and SMS buttons (`url_launcher`). The request's blood group and district pre-fill the filters.
- **After the request closes** (Fulfilled, Cancelled or expired), numbers are hidden again.
- **Implementation:** phone numbers live in a separate `donor_contacts` table. Its RLS rule allows reading only when the viewer has an open request and the donor is Green or Yellow. RLS works on rows, so the number cannot sit in the publicly readable profile table.

### Blood group matching

Search and request alerts include every donor group compatible with the patient's group, based on standard red-cell compatibility. Search lists exact-group donors first, then compatible donors labelled "Compatible". The hospital's crossmatch test still makes the final decision.

| Patient's group | Donor groups that can give |
| --- | --- |
| O− | O− |
| O+ | O+, O− |
| A− | A−, O− |
| A+ | A+, A−, O+, O− |
| B− | B−, O− |
| B+ | B+, B−, O+, O− |
| AB− | AB−, A−, B−, O− |
| AB+ | All groups |

Store this table in Supabase as a lookup table so the matching queries and the Edge Function share one source.

## Blood requests

Requests go live immediately with no approval step, and only the poster can close them.

- **Who can post:** any logged-in user.
- **Fields:** patient name, blood group, units needed, hospital (free text), district, required date, contact phone, notes.
- **Status:** Open → Fulfilled, or Open → Cancelled.
- **Auto-expiry:** a request closes itself 48 hours after its required date.
- **Limits:** at most 3 open requests per user; the required date cannot be in the past. Enforce both in the database, not only in the app.
- **Seeker's contact phone:** visible only to donors opening the request, from a notification or from the app.
- **My Requests:** each user's own requests with status and Fulfilled/Cancel actions.
- **Open Requests:** donors see open requests in their district, with requests their blood group is compatible with shown first.

## "I'm Interested" flow

A donor who taps "I'm Interested" on a request is hidden for 3 hours, then asked on the evening of the required date whether they donated.

1. **Donor taps "I'm Interested"** on an open request.
   - The response is recorded, and the seeker sees the donor and their phone number.
   - The donor is hidden from search for 3 hours.
   - They cannot respond to another request during that time.
2. **At 8 PM on the request's required date, or 3 hours after the tap if that is later**, the app asks: "Did you successfully donate blood?"
   - **Yes:** a donation is recorded and the donor becomes Yellow.
   - **No:** the donor returns to their previous status, unless they changed it manually.
3. **No answer:** one reminder is sent. 24 hours after the first question, the donor returns to their previous status. The question stays on the dashboard, so they can still answer Yes later.
4. **Request closes early:** interested donors are notified "This request was closed by the seeker."
   - **Cancelled:** the donor returns to their previous status immediately.
   - **Fulfilled:** the donor gets the "Did you donate?" question right away.

## Notifications and emergency alerts

Push notifications use Firebase Cloud Messaging, sent by Supabase Edge Functions. Donors with "Receive alerts" OFF get no request or emergency alerts.

| Notification | Trigger | Who receives it |
| --- | --- | --- |
| New request alert | A request is posted | Green donors whose blood group is compatible with the patient's (see Blood group matching), in the hospital's district |
| Emergency alert | Seeker taps Emergency Alert, at most once every 15 days | All donors in the hospital's district, any blood group or status |
| "Did you donate?" | 8 PM on the required date, or 3 hours after "I'm Interested" if later | That donor, plus one reminder |
| Request closed | Seeker marks Fulfilled or Cancelled | Donors who tapped "I'm Interested" |

- **Emergency alert purpose:** reach donors who may not match but might know someone who can donate.
- **"Receive alerts" switch:** independent of availability; default ON.
- **No direct alert to a single donor** in version 1.
- **Rate limits:** the 15-day emergency limit is enforced on the server, not only in the app.

## Postponed and out of scope

These are not in version 1:

- Hospital directory, possibly from an API later. OpenStreetMap's free Overpass API is one option.
- Health tips, About, Contact/Feedback and Privacy screens.
- Forgot password.
- Reporting fake profiles or requests.
- SMS OTP verification.
- In-app messaging.
- Alerting one specific donor directly.

## Open items

- Requirements 01–07 were not available. Check them against this list and keep the later decision wherever they conflict.
- Confirm the 84/112-day gaps and the 18–60 age range with a Bangladeshi source or your faculty.
