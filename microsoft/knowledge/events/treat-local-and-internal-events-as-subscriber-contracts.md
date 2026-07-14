---
bc-version: [all]
domain: events
keywords: [local-event, internal-event, event-subscriber, compatibility, access-modifier, integration-event, business-event, parameter-name, var-parameter, appsourcecop]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Treat local and internal events as subscriber contracts

## Description

The `local` and `internal` access modifiers on Business and Integration event publishers restrict who can raise the procedure; they do not prevent dependent extensions from subscribing. Once shipped, the event name and each existing parameter's name, type/subtype, and value-versus-`var` passing mode are compatibility contracts even when the publisher is not public. Parameter order is not a subscriber contract because subscribers bind the parameters they use by name. This differs from `[InternalEvent]`, which is module-only except for modules named by `internalsVisibleTo`.

## Best Practice

Preserve a shipped Business or Integration event's identity and every existing parameter's name, type/subtype, and passing mode regardless of the procedure access modifier. AS0025 protects names and types, while AS0063 and AS0077 protect removal and addition of `var`. New parameters may be added at any position on a `local` or `internal` event because subscribers can omit them; public event procedures follow the stricter caller contract described by `add-new-event-parameters-at-the-end`.

See sample: `treat-local-and-internal-events-as-subscriber-contracts.good.al`.

## Anti Pattern

Renaming or removing an existing parameter, changing its type/subtype, or adding/removing its `var` modifier because the event publisher procedure is `local` or `internal`. AppSourceCop checks these subscriber-breaking changes because dependent event subscribers can still bind to the event. Reordering unchanged parameters, or inserting a new parameter among them, is not this anti-pattern.

See sample: `treat-local-and-internal-events-as-subscriber-contracts.bad.al`.
