---
bc-version: [all]
domain: events
keywords: [event-parameters, signature, backward-compatibility, append, onbefore, integration-event, versioning]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Add new event parameters at the end

## Description

Adding a parameter to an existing event publisher changes its signature. For a `local` or `internal` Business or Integration event, subscribers may omit parameters, so a new parameter can be compatible when appended at the end. A public event is also a public procedure that dependent extensions can raise; adding a parameter to it is breaking and requires a new event. Existing parameters must never be renamed, removed, reordered, or have their type changed.

## Best Practice

When extending an existing `local` or `internal` Business or Integration event, append the new parameter after all existing ones, including after a trailing `var IsHandled: Boolean` when present. Existing subscribers can continue omitting the new trailing parameter. Create a new event instead when the publisher procedure is public.

See sample: `add-new-event-parameters-at-the-end.good.al`.

## Anti Pattern

Inserting a new parameter before an existing parameter of a `local` or `internal` event, or adding any parameter to a public event. Detection: a changed event signature where a new parameter is not a compatible trailing addition.

See sample: `add-new-event-parameters-at-the-end.bad.al`.
