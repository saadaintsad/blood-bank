---
version: 1
slug: "lib"
primary_target: "lib"
related_targets: []
---

Scope: Reddify app UI (all screens under lib/). Mode: Operate.

Audience/task: blood seekers find an available donor by blood group + district and call them; donors keep availability current. Constraints: Flutter Material 3 + google_fonts only, 48dp targets, AA contrast, no network images, beginner-readable code.

## Direction contract

THESIS: The donor card is the identity of the app. A blood group is a stamp, never a pill: it is the one thing a seeker scans for. Refuses the category default of red drops, hearts-in-hands and a pink hero banner.

OWN-WORLD: Soft card-stock ground #F4F1EC, cards #FFFDF9 with a 1px warm hairline, deep crimson ink #A3122A for primary actions and stamps, slate ink #1E2326 for text and the secondary dark action, green #1D6B3A only for availability. Archivo throughout. Blood group set in heavy Archivo inside a square crimson-bordered stamp; the hero stamp is a double border tilted a few degrees.

STORY: The visitor sees their own donor card or the search, recognises their blood group instantly, reads urgent requests by group/bags/hospital/time, and calls a donor in one tap.

FIRST VIEWPORT: Crimson header band with Reddify and tagline; the donor card overlaps its lower edge with the large tilted stamp at left; urgent requests below as rows of [stamp | bags · hospital / time | 48dp call button]; slate "Request blood" extended FAB; bottom navigation bar with Home, Donors, Requests, Profile.

FORM: Donor Card Stamp, position 1 on my ordered list (chosen as IMPECCABLE'S PICK over the assigned Kantha Thread). seed:4b71669ea32c17a6

Raises carried: blood group always in the same fixed cell at row left; status as fixed stations; destructive actions isolated and outlined; state by shape + label, not colour alone.

FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
