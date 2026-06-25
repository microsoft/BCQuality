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

Adding a parameter to an existing event publisher changes its signature. Appending the new parameter at the end of the parameter list keeps the change easy to review and track: existing subscribers still bind to the leading parameters, and the diff is a single clean addition. Inserting a parameter in the middle makes diffs noisy and harder to review, and obscures the history of how the signature evolved. New parameters belong after the existing ones.

## Best Practice

When extending an existing publisher, append the new parameter after all existing ones, including after a trailing `var IsHandled: Boolean` when present. Subscribers that already match keep working against the leading parameters, and the change stays a one-line addition that is trivial to review.

See sample: `add-new-event-parameters-at-the-end.good.al`.

## Anti Pattern

Inserting a new parameter in the middle of an existing event's signature, shifting every subsequent parameter and making the change noisy and harder to review. Detection: a changed event signature where an added parameter appears before existing parameters rather than at the tail of the list.

See sample: `add-new-event-parameters-at-the-end.bad.al`.
