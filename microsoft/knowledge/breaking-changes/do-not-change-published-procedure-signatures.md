---
bc-version: [all]
domain: breaking-changes
keywords: [signature, public-procedure, parameter, return-value, overload, contract]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not change the signature of a published procedure

## Description

A procedure that is reachable from outside its object — any procedure not marked `local` (and, for on-prem-scoped code, anything a dependent app can still bind to) — is a contract. Once another extension compiles against it, changing its shape breaks that extension at build time. Signature changes include adding, removing, or reordering parameters, changing a parameter or return type, and toggling a parameter between by-value and `var` (by-reference). The platform treats the procedure's identity as its full signature, so even a "compatible-looking" tweak is a new method to dependents. There is exactly one safe edit: naming a previously unnamed return value, which adds no caller obligation. LLMs routinely "improve" a public procedure in place by adding a parameter, not realizing every consumer must be recompiled.

## Best Practice

Treat a published signature as frozen. When new behavior needs more inputs, add a new procedure or overload alongside the original — for example a `CalculateDiscountWithRate(Amount; Rate)` next to the unchanged `CalculateDiscount(Amount)` — and let the old one delegate to the new one. Existing callers keep compiling; new callers opt into the richer entry point. Naming an unnamed return value is the one in-place change that is always safe.

See sample: `do-not-change-published-procedure-signatures.good.al`.

## Anti Pattern

Editing the existing public procedure's parameter list — here, adding a `Rate` parameter to `CalculateDiscount` — so every dependent extension that called the old form fails to compile. Detection: a parameter added, removed, reordered, retyped, or flipped to/from `var`, or a changed return type, on any non-`local` procedure that already shipped. Add a new overload instead.

See sample: `do-not-change-published-procedure-signatures.bad.al`.
