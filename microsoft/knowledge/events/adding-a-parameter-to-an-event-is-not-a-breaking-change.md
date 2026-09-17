---
bc-version: [all]
domain: events
keywords: [event-parameters, signature, subscriber-binding, backward-compatibility, integration-event, breaking-change, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Adding a parameter to an event is not a breaking change

## Description

Adding a parameter to an existing event publisher does not break existing subscribers. AL binds a subscriber to a publisher by the event name, and the subscriber's parameter list only has to be a subset of the publisher's, matched by name and type. A subscriber that does not declare the new parameter keeps compiling and keeps binding — it simply ignores the addition. This holds for `IntegrationEvent` and `BusinessEvent` publishers, and even more plainly for `local` events. Appending the new parameter at the end keeps the change a clean, reviewable addition (see `add-new-event-parameters-at-the-end`). LLM reviewers often misreport the mere presence of a new event parameter as a "breaking event signature change" that breaks subscribers, which is incorrect.

## Best Practice

Do not flag the addition of a parameter to an event publisher as a breaking or signature-breaking change, and do not claim it breaks existing subscribers. Genuine, separate concerns are covered by their own rules — a parameter inserted in the middle of the list rather than appended (`add-new-event-parameters-at-the-end`), or a parameter that carries no meaningful value — and should be raised on those grounds, not framed as a backward-compatibility break.
