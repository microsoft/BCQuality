---
bc-version: [all]
domain: breaking-changes
keywords: [signature, public-procedure, parameter, return-value, overload, contract, integration-event]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not change the signature of a published procedure

## Description

A procedure that is reachable from outside its object — any procedure not marked `local` (and, for on-prem-scoped code, anything a dependent app can still bind to) — is a contract. Once another extension compiles against it, changing its shape breaks that extension at build time. Signature changes include adding, removing, or reordering parameters, changing a parameter or return type, and toggling a parameter between by-value and `var` (by-reference). The platform treats the procedure's identity as its full signature, so even a "compatible-looking" tweak is a new method to dependents. There is exactly one safe edit: naming a previously unnamed return value, which adds no caller obligation. LLMs routinely "improve" a public procedure in place by adding a parameter, not realizing every consumer must be recompiled.

This rule governs procedures that dependents *call*. An event publisher — a procedure carrying `[IntegrationEvent]` or `[BusinessEvent]`, conventionally declared `local` — is bound to, not called, and AL binds each subscriber parameter by name rather than by position. Adding a parameter to a shipped event therefore leaves every existing subscriber binding successfully, at any position in the list, so it is additive rather than breaking and must not be flagged under this rule. See `events/adding-a-parameter-to-an-event-is-not-a-breaking-change` for the full treatment, and `events/add-new-event-parameters-at-the-end` for when publisher access does make the addition breaking. Every other edit to a published event signature — removing or retyping a parameter, renaming one, or flipping one to or from `var` — still breaks subscribers, and `events/treat-local-and-internal-events-as-subscriber-contracts` owns that case together with the analyzer rules that enforce it: AS0025 for parameter names and types, AS0063 for removing `var`, and AS0077 for adding it. Adding `var IsHandled: Boolean` is a separate concern: it binds fine but changes the event's contract, and is covered by `events/do-not-add-ishandled-to-an-existing-event`.

## Best Practice

Treat a published signature as frozen. When new behavior needs more inputs, add a new procedure or overload alongside the original — for example a `CalculateDiscountWithRate(Amount; Rate)` next to the unchanged `CalculateDiscount(Amount)` — and let the old one delegate to the new one. Existing callers keep compiling; new callers opt into the richer entry point. Naming an unnamed return value is the one in-place change that is always safe.

See sample: `do-not-change-published-procedure-signatures.good.al`.

## Anti Pattern

Editing the existing public procedure's parameter list — here, adding a `Rate` parameter to `CalculateDiscount` — so every dependent extension that called the old form fails to compile. Detection: a parameter added, removed, reordered, retyped, or flipped to/from `var`, or a changed return type, on any non-`local` procedure that already shipped. Add a new overload instead. Exclude event publishers whose only change is an added parameter: subscribers bind by parameter name, not position, so that edit is additive and reporting it here is a false positive.

See sample: `do-not-change-published-procedure-signatures.bad.al`.
