---
bc-version: [all]
domain: style
keywords: [object-id, page-run, report-run, codeunit-run, named-invocation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Invoke objects by name, not by numeric ID

## Description

AL supports calling `Page.RunModal(525, ...)` or `Report.Run(206, ...)` with a bare numeric ID. The platform accepts the number, but the call site loses every signal that makes the code reviewable and refactor-safe: the reader cannot tell which object is being invoked without looking up 525 in the object catalog, and the renumbering of an object in a future release (legal in AL — IDs are not a stable contract) silently retargets the call to a different object. The `Page::"..."` / `Report::"..."` syntax compiles to the same runtime call but makes the target explicit and binds by name, which is the stable identity.

## Best Practice

Write `Page.RunModal(Page::"Posted Sales Shipment Lines", SalesShptLine)` and `Report.Run(Report::"Sales - Invoice", true)`. Apply the same rule to `Codeunit.Run`, `XmlPort.Run`, and similar runtime invocations. Reserve numeric IDs for diagnostic tooling that genuinely needs them.

See sample: `use-named-invocations-instead-of-object-ids.good.al`.

## Anti Pattern

`Page.RunModal(525, SalesShptLine);` — the reader has no idea what page 525 is without a lookup, and a future rename of page 525 or renumber of "Posted Sales Shipment Lines" produces a silent mismatch.

See sample: `use-named-invocations-instead-of-object-ids.bad.al`.
