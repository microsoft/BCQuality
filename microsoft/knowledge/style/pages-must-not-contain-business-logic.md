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

A page procedure that persists a business mutation directly (`Rec.Modify()` outside the standard record-bound save, or a cross-entry-point business rule implemented only in a page trigger) is an architecture violation even when it compiles: the rule only applies when a user opens that specific page, and silently doesn't run through any other entry point (API, batch job, another page). This is narrower than "no calculation may live on a page" — a presentation-specific calculation (formatting, a derived display value) is fine on the page that shows it, and a reusable data invariant commonly belongs on the table itself (a field's own validation/trigger), not forced into a codeunit merely to keep it off the page. The actual line is entry-point independence: a business operation or invariant that must hold regardless of which entry point touches the record belongs in a codeunit or the table, not solely in one page's trigger.

A narrow set of patterns are conventional rather than violations:
- A setup page reading and writing its own singleton setup record.
- A dedicated "Run Conversion" page invoking a conversion codeunit directly.
- The standard singleton-initialization idiom on `OnOpenPage` (`if not Rec.Get() then begin Rec.Init(); Rec.Insert(); end`) used by cue/activities pages to bootstrap their own presentation-state record — this is not business logic, it is the same pattern used throughout base-app cue pages.

## Best Practice

Delegate all business operations to a codeunit: the page owns presentation, the codeunit owns logic. A calculation or validation triggered from a page action should call a codeunit procedure rather than compute the result inline.

See sample: `pages-must-not-contain-business-logic.good.al`.

## Anti Pattern

A cross-entry-point business rule or persisted mutation implemented only in a page trigger — calling `Rec.Modify()` to save a computed business value from `OnValidate`/`OnAction`, or a validation that must hold regardless of caller, instead of routed through a codeunit or the table's own field validation. A presentation-only calculation or a table-owned field invariant is not an instance of this anti-pattern.

See sample: `pages-must-not-contain-business-logic.bad.al`.
