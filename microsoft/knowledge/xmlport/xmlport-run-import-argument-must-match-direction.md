---
bc-version: [all]
domain: xmlport
keywords: [xmlport, xmlport-run, direction, import, export, requestwindow, runtime-error]
technologies: [al]
countries: [w1]
application-area: [all]
---

# The `Import` argument of `Xmlport.Run` must match the XMLport's `Direction`

## Description

`Xmlport.Run(Number [, RequestWindow] [, Import] [, Record])` takes an optional `Import` argument that says whether the XMLport imports or exports, and its default is `true`. When the XMLport's `Direction` property is `Import` or `Export`, the argument must agree with that direction or the call fails at run time. The consequence is easy to miss: running an export-only XMLport as `Xmlport.Run(Id, false)` leaves `Import` at its default of `true`, which contradicts `Direction = Export`. The call compiles, and the mismatch appears only when the code runs.

The argument selects the direction only when `Direction` is `Both` and no request page is shown. With a request page, it sets the default of the direction option the user sees.

## Best Practice

When calling `Xmlport.Run` on an XMLport with `Direction = Export`, pass `false` for `Import` explicitly. For `Direction = Import`, the default is already correct; passing `true` documents the intent. For `Direction = Both`, always pass the argument so the direction does not depend on a default.

See sample: [`xmlport-run-import-argument-must-match-direction.good.al`](xmlport-run-import-argument-must-match-direction.good.al).

## Anti Pattern

`Xmlport.Run(Xmlport::"Customer Export", false);` against an XMLport declared with `Direction = Export`. The author suppressed the request page and assumed the declared direction would be used; the omitted third argument defaults to import and the call raises a run-time error. Reviewer signal: a two-argument `Xmlport.Run` whose target XMLport is export-only.

Do not report a two-argument call when the target's `Direction` is `Import`, and do not infer the direction from the XMLport's name when its definition is not available.

See sample: [`xmlport-run-import-argument-must-match-direction.bad.al`](xmlport-run-import-argument-must-match-direction.bad.al).

## References

[Xmlport.Run method](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/xmlport/xmlport-run-method) and [Direction property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-direction-property).
