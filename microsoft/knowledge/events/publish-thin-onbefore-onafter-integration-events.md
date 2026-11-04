---
bc-version: [all]
domain: events
keywords: [integration-event, onbefore, onafter, extension-point, thin-publisher, publisher-body, extensibility, integration-requirement, operation-boundary]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Publish thin OnBefore/OnAfter integration events to expose extension points

## Description

Integration events expose defined extension points for supported customization scenarios. A posting, release, or validation routine does not need an `OnBefore`/`OnAfter` pair merely because it is public or performs business logic. Establish the required customization and whether existing events or another supported extension mechanism already provide it before recommending a new publisher. An event publisher is a thin hook with an empty body; the calling routine owns the business logic.

## Best Practice

For an established extension requirement, expose a purpose-specific event at the boundary that provides the required data and timing; reuse or extend an existing suitable event before adding a new one. The requirement may be established by a documented extension contract, an accepted customization requirement, or visible integration behavior; an already-present subscriber is not required. Do not mechanically add both `OnBefore` and `OnAfter`, mutable record parameters, or an `IsHandled` override to every routine. Choose parameters for the supported operation, preserving required validation and authorization. Use `IsHandled` only where overriding the operation is genuinely necessary and a better extension mechanism is unavailable. Declare thin publishers with empty bodies and keep business logic in the calling routine. This guidance does not authorize removing or changing shipped events or their subscriber contracts.

See sample: [`publish-thin-onbefore-onafter-integration-events.good.al`](publish-thin-onbefore-onafter-integration-events.good.al).

## Anti Pattern

For missing-event findings, identify the supported customization that is blocked, the required data or timing, and why an existing event or other supported extension mechanism cannot satisfy it. The absence of surrounding `OnBefore`/`OnAfter` publishers on a posting or validation routine is not sufficient evidence by itself. Conversely, absence of a visible consumer does not prove that an established extension contract is unnecessary.

See sample: [`publish-thin-onbefore-onafter-integration-events.bad.al`](publish-thin-onbefore-onafter-integration-events.bad.al).

## References

- [Using the IsHandled pattern](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-use-ishandled-pattern) — limit overrides to necessary cases; prefer purposeful extensibility that preserves validation.
- [Types of events for extensibility](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/types-of-events-for-extensibility) — choose events by their purpose and operation boundary, rather than adding hooks mechanically.
- [Reuse existing events](prefer-reusing-or-extending-existing-events.md) and [preserve subscriber contracts](treat-local-and-internal-events-as-subscriber-contracts.md).
