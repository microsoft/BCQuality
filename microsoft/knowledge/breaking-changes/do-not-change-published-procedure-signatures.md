---
bc-version: [all]
domain: breaking-changes
keywords: [signature, public-procedure, parameter, return-value, overload, contract, integration-event, integer-to-biginteger]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not change the signature of a published procedure

## Description

A procedure that is reachable from outside its object — any procedure not marked `local` (and, for on-prem-scoped code, anything a dependent app can still bind to) — is a contract. Adding, removing, or reordering parameters, changing parameter or return types, and toggling by-value versus `var` passing can break dependent extensions. Not every signature edit is a breaking change: naming an unnamed return value adds no caller obligation, and runtime 18.0 (BC 29) introduces support for `Integer`-to-`BigInteger` widening, including procedure parameters and return values. Widening a procedure's local variable is not a published signature change at all.

This rule governs procedures that dependents *call*. An event publisher — a procedure carrying `[IntegrationEvent]` or `[BusinessEvent]`, conventionally declared `local` — is bound to, not called, and AL binds each subscriber parameter by name rather than by position. Adding a parameter to a shipped event therefore leaves every existing subscriber binding successfully, at any position in the list, so it is additive rather than breaking and must not be flagged under this rule. See `events/adding-a-parameter-to-an-event-is-not-a-breaking-change` for the full treatment, and `events/add-new-event-parameters-at-the-end` for when publisher access does make the addition breaking. Removing or renaming existing event parameters, unsupported retyping, and changing `var` are separate subscriber-contract concerns owned by `events/treat-local-and-internal-events-as-subscriber-contracts`. Adding `var IsHandled: Boolean` binds fine but changes the event's contract, and is covered by `events/do-not-add-ishandled-to-an-existing-event`.

## Best Practice

Preserve published signatures except for supported compatible changes. When new behavior needs more inputs, add a new procedure or overload alongside the original — for example a `CalculateDiscountWithRate(Amount; Rate)` next to the unchanged `CalculateDiscount(Amount)` — and let the old one delegate to the new one. Naming an unnamed return value is safe.

On runtime 18.0 and later, do not demand an overload or obsoletion solely because an existing `Integer` parameter or return value becomes `BigInteger`. Preserve parameter order and existing `var` modifiers; the widening exception does not cover unrelated signature edits. Follow widened ledger identifiers through local variables, parameters, returns, collections, and register bounds instead of retaining `Integer` just to avoid a supposed API break.

Platform compatibility does not increase an existing `Integer` consumer's capacity. Review assignments of widened returns and output `var` values back into `Integer`: values above 2,147,483,647 can overflow. Identify the concrete narrowing path and migrate affected dependents; do not describe the widening itself as an unconditional compile-time break or promise that every old consumer can handle the larger range. Check the target runtime, symbols, and applicable analyzer diagnostics.

See sample: [`do-not-change-published-procedure-signatures.good.al`](do-not-change-published-procedure-signatures.good.al).

## Anti Pattern

Editing the existing public procedure's parameter list — here, adding a `Rate` parameter to `CalculateDiscount` — so every dependent extension that called the old form fails to compile. Flag added, removed, or reordered callable parameters, unsupported retyping (including `BigInteger`-to-`Integer` narrowing), and changes to `var`; use a new API for those changes. Exclude supported `Integer`-to-`BigInteger` parameter/return widening on runtime 18.0+, local-variable widening, and event publishers whose only change is an added parameter. Requiring an obsolete overload solely for supported widening is also a false positive; report actual overflow risks separately.

See sample: [`do-not-change-published-procedure-signatures.bad.al`](do-not-change-published-procedure-signatures.bad.al).

## References

- [AS0147: parameter widening from runtime 18.0, with dependent-extension caveats](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0147).
- [Base Application migration](https://github.com/microsoft/BCApps/pull/10834), including [G/L Entry's widened GetNextEntryNo and GetLastEntryNo returns](https://github.com/microsoft/BCApps/blob/2e45393bf238b07d4f47a5839ba1a8a9ce07520d/src/Layers/W1/BaseApp/Finance/GeneralLedger/Ledger/GLEntry.Table.al), is public implementation evidence for return-value widening.
