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

Adding a parameter to an existing event publisher changes its signature, and every subscriber must be updated to match. Appending the new parameter at the end of the parameter list keeps the change easy to review and minimizes churn: existing subscribers still bind to the leading parameters, and the diff is a single clean addition. Inserting a parameter in the middle shifts every following argument, makes diffs noisy, and is error-prone to reconcile across many subscribers — a subscriber that compiles can still receive the wrong values because positions moved. New parameters belong after the existing ones.

## Best Practice

When extending an existing publisher, append the new parameter after all existing ones, including after a trailing `var IsHandled: Boolean` when present. Subscribers that already match keep working against the leading parameters, and the change stays a one-line addition that is trivial to review.

See sample: `add-new-event-parameters-at-the-end.good.al`.

## Anti Pattern

Inserting a new parameter in the middle of an existing event's signature, shifting the position of every subsequent argument and forcing a careful re-map of all subscribers. Detection: a changed event signature where an added parameter appears before existing parameters rather than at the tail of the list.

See sample: `add-new-event-parameters-at-the-end.bad.al`.
