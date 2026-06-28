---
bc-version: [all]
domain: events
keywords: [event-reuse, duplication, consecutive-events, extension-point, onbefore, integration-event, maintainability]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer reusing or extending existing events

## Description

Before adding a publisher, check whether an event already fires at that point in the code. Two related smells signal that you should reuse or extend instead of adding one. The first is a brand-new event placed directly next to an existing one — two consecutive event raises with no logic between them, which gives subscribers two seams where one belongs. The second is a near-duplicate event that differs from an existing one only by an extra parameter. Both bloat the publisher surface and leave subscribers unsure which event to pick. Prefer subscribing to the existing event, or extending it by appending the parameter you need, over introducing a parallel one.

## Best Practice

When the data you need is already exposed at an existing event, subscribe to it. When the event lacks a parameter, extend that event by appending the parameter at the end — one publisher, one raise — rather than adding a second event beside it.

See sample: `prefer-reusing-or-extending-existing-events.good.al`.

## Anti Pattern

Adding a second event raise immediately after an existing one, or creating `OnBeforeProcessOrderWithCustomer` next to `OnBeforeProcessOrder` just to add a single parameter. Detection: two consecutive `OnBefore…`/`OnAfter…` raises with no logic between them, or near-duplicate event names differing only by a parameter-describing suffix.

See sample: `prefer-reusing-or-extending-existing-events.bad.al`.
