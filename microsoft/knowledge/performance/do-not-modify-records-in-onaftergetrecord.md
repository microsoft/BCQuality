---
bc-version: [all]
domain: performance
keywords: [onaftergetrecord, modify, page, trigger, write-per-scroll]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not Modify records inside OnAfterGetRecord

## Description

`OnAfterGetRecord` fires for every row the page or repeater renders. On a list page the user scrolls through, the trigger runs hundreds of times per second. A `Modify()` call inside the trigger writes to the database for every row scrolled past — the user's mouse wheel generates the write storm, and the effect compounds with every other subscriber that reacts to the OnModify event. The database activity is usually invisible to the author in development, because the list page loads ten rows; on a production tenant scrolling through thousands of rows, the page becomes the top source of write volume.

## Best Practice

Derive display-only state into a page-level variable and bind that variable to the field control instead of writing to `Rec`. If the computed value is genuinely a stored attribute of the record, compute it once at the authoring site (OnValidate, OnInsert) and display the stored value on the list — do not recompute and rewrite on every render.

See sample: `do-not-modify-records-in-onaftergetrecord.good.al`.

## Anti Pattern

An OnAfterGetRecord body that assigns a computed value to `Rec."Warning Flag"` and calls `Rec.Modify()` so the flag persists. The write fires per scroll, per user, per second — and every subscriber on the Rec's OnModify fires alongside.

See sample: `do-not-modify-records-in-onaftergetrecord.bad.al`.
