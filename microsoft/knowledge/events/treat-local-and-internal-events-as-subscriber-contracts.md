---
bc-version: [all]
domain: events
keywords: [local-event, internal-event, event-subscriber, compatibility, access-modifier, integration-event, business-event, appsourcecop, as0025]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Treat local and internal events as subscriber contracts

## Description

The `local` and `internal` access modifiers on Business and Integration event publishers restrict who can raise the procedure; they do not prevent dependent extensions from subscribing. Once shipped, the event name and existing parameter names, types, order, and passing modes are compatibility contracts even when the publisher is not public. This differs from `[InternalEvent]`, which is module-only except for modules named by `internalsVisibleTo`.

## Best Practice

Preserve a shipped Business or Integration event's identity and existing parameters regardless of its procedure access modifier. A compatible trailing parameter may be added to a `local` or `internal` event as described by `add-new-event-parameters-at-the-end`; for an incompatible signature or a public publisher, add a new event and keep the original.

See sample: `treat-local-and-internal-events-as-subscriber-contracts.good.al`.

## Anti Pattern

Renaming, removing, reordering, or changing an existing parameter because the event publisher procedure is `local` or `internal`. AppSourceCop AS0025 checks these subscriber-breaking changes because dependent event subscribers can still bind to the event.

See sample: `treat-local-and-internal-events-as-subscriber-contracts.bad.al`.
