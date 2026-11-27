---
bc-version: [all]
domain: events
keywords: [event-parameters, signature, subscriber-binding, backward-compatibility, integration-event, breaking-change, false-positive, as0024]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Adding a parameter to an event is not a breaking change

## Description

Adding a parameter to an existing event publisher does not break existing subscribers. AL binds a subscriber to a publisher by the event name, and the subscriber's parameter list only has to be a subset of the publisher's, matched by name and type. A subscriber that does not declare the new parameter keeps compiling and keeps binding — it simply ignores the addition. This holds for `IntegrationEvent` and `BusinessEvent` publishers at any position in the parameter list; appending is not required. The one exception concerns callers, not subscribers: a publisher declared without `local` or `internal` is also a public procedure that dependent extensions can raise, and a new required parameter breaks those callers under AppSourceCop AS0024 (see `add-new-event-parameters-at-the-end`). LLM reviewers often misreport the mere presence of a new event parameter as a "breaking event signature change" that breaks subscribers, which is incorrect.

## Best Practice

Do not flag the addition of a parameter to a `local` or `internal` event publisher as a breaking or signature-breaking change, whatever its position in the list, and never claim that an added parameter breaks existing subscribers. Genuine, separate concerns are covered by their own rules — a parameter added to a public event procedure, which breaks dependent extensions that raise it (`add-new-event-parameters-at-the-end`), or a parameter that carries no meaningful value — and should be raised on those grounds, not framed as a subscriber break.
