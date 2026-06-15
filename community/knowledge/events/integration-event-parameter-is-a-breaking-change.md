---
bc-version: [all]
domain: events
keywords: [integration-event, publisher, subscriber, breaking-change, parameter, obsolete]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Adding a parameter to an existing integration event is a breaking change

## Description

Every codeunit that subscribes to an `[IntegrationEvent]` must match the publisher's exact parameter signature. Adding a parameter to an existing event immediately breaks every subscriber — they fail to compile the moment the parameter is added to the publisher. This affects all consumers of the event, including those in other extensions the author does not control.

## Best Practice

Add a new event with the extended signature alongside the original. Keep the original event and mark it `[Obsolete(...)]` so existing subscribers continue to compile and authors have time to migrate. The new event name should reflect the addition (for example, append `WithShipmentNo` or increment a suffix). Raise both events during the transition period.

See sample: `integration-event-parameter-is-a-breaking-change.good.al`.

## Anti Pattern

Adding a new parameter directly to the existing `[IntegrationEvent]` declaration. Every subscriber codeunit, in every extension that subscribed to that event, stops compiling immediately. There is no safe rollout path once the breaking signature is published.

See sample: `integration-event-parameter-is-a-breaking-change.bad.al`.
