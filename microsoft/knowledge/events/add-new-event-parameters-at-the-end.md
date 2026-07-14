---
bc-version: [all]
domain: events
keywords: [event-parameters, signature, backward-compatibility, public-event, local-event, internal-event, appsourcecop, as0024, as0025]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Event parameter additions depend on publisher access, not position

## Description

Event subscribers bind publisher parameters by name and can omit parameters they do not use. A `local` or `internal` Business or Integration event can therefore gain a parameter at any position without breaking subscriber-only consumers; appending is not a compatibility requirement. A public event is also a public procedure that dependent extensions can raise, so adding a required parameter anywhere breaks callers under AppSourceCop AS0024.

## Best Practice

Add a parameter directly only when the shipped event publisher is `local` or `internal`. Place it where the signature is clearest; existing subscribers continue binding the parameters they name. For a public event, keep the original publisher unchanged and introduce a new event with the expanded contract.

See sample: `add-new-event-parameters-at-the-end.good.al`.

## Anti Pattern

Appending a parameter to a public event and assuming its position makes the change compatible. Existing external callers still lack the new required argument. Conversely, do not flag a parameter inserted among existing parameters on a `local` or `internal` Business or Integration event merely because it was not appended.

See sample: `add-new-event-parameters-at-the-end.bad.al`.
