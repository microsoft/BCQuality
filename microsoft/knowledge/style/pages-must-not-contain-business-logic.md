---
bc-version: [all]
domain: style
keywords: [pages, business-logic, codeunit, separation-of-concerns, presentation-layer]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep business logic out of page objects

## Description

A page procedure that calculates a value and assigns it to a field, calls `Rec.Modify()` directly, or implements a business rule is an architecture violation even when it compiles. Pages are a presentation layer: they bind data to the UI and invoke actions. Calculations, validations, and record mutations belong in codeunits, where they can be tested, reused, and called consistently regardless of which page (or API, or batch job) triggers them. When logic lives on a page, it only applies when a user opens that specific page — the same business rule silently doesn't run through any other entry point.

A narrow set of patterns are conventional rather than violations:
- A setup page reading and writing its own singleton setup record.
- A dedicated "Run Conversion" page invoking a conversion codeunit directly.
- The standard singleton-initialization idiom on `OnOpenPage` (`if not Rec.Get() then begin Rec.Init(); Rec.Insert(); end`) used by cue/activities pages to bootstrap their own presentation-state record — this is not business logic, it is the same pattern used throughout base-app cue pages.

## Best Practice

Delegate all business operations to a codeunit: the page owns presentation, the codeunit owns logic. A calculation or validation triggered from a page action should call a codeunit procedure rather than compute the result inline.

See sample: `pages-must-not-contain-business-logic.good.al`.

## Anti Pattern

Direct calculations in a page trigger (e.g. `Rec."Total Amount" := Rec.Quantity * Rec."Unit Price"`), calls to `Rec.Modify()` from a page trigger, or business-rule validation embedded in `OnValidate`/`OnAction` instead of routed through a codeunit.

See sample: `pages-must-not-contain-business-logic.bad.al`.
