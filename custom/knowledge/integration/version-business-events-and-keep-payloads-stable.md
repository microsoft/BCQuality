---
bc-version: [all]
domain: integration
keywords: [business-events, versioning, dto, payload-contract, validate, transient-permanent, breaking-change]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Version business events and keep payloads stable

## Description

A business event payload is a published contract. Once an external subscriber has bound to an event's name and signature, that signature is no longer yours to change quietly: adding a parameter, reordering parameters, or retyping one changes the shape the subscriber receives, and because external subscribers live outside your app there is no compiler to catch the break. The notification simply starts arriving in a shape the consumer does not expect, and the failure surfaces as malformed data or dropped processing on the far side, often long after the change shipped and far from the code that caused it.

Two disciplines keep the contract honest. The first is versioning: treat a shipped event signature as frozen, and express any change as a new procedure or a new codeunit rather than an edit to the old one, so existing subscribers keep receiving exactly what they bound to while new subscribers opt into the new shape. The second is payload hygiene: the payload must be a minimal, stable DTO of identifiers and just enough context, never the raw BC record (which exposes every field and couples the contract to the table layout) and never a secret such as an API key or token (which leaks credentials to every subscriber). A payload that must also be validated before firing, so invalid data is never published and then retried forever.

## Best Practice

Put all events for one integration version in a single events codeunit, and give a second version its own codeunit. Name each procedure with its version suffix (`OnOrderConfirmed_v1`) so the version is visible at the call site and a new version sits beside the old one rather than replacing it. Pass a small DTO of identifiers so a subscriber can call back for detail without the payload leaking fields or secrets. Validate the payload before firing, so a record that cannot produce a meaningful notification fails fast rather than being published and retried indefinitely. Classify failures as transient (network, subscriber temporarily down: let the platform retry) versus permanent (invalid data, a malformed payload: fail, alert, and consider a dead-letter path) so a permanent error is not retried for 36 hours as if it were a blip. See `version-business-events-and-keep-payloads-stable.good.al`.

The trade-off is more codeunits over time as versions accumulate, which is the correct cost: a stable contract for existing consumers is worth more than a tidy single signature that silently breaks them.

## Anti Pattern

Adding or reordering parameters on an already-published event, passing the whole BC record or secret-bearing fields as the payload, or firing without validating first. The detection signal: an edit to the signature of an existing `[ExternalBusinessEvent]` or `[BusinessEvent]` that has already shipped, a parameter typed as a full table record (`var Rec: Record ...`) on an event, a payload field that holds a key or token, or a fire with no prior validation and no transient-versus-permanent classification of the failure. The consequence is silently broken subscribers (signature change), leaked data or credentials (record or secret payload), and infinite retry of unfixable data (no validation). The fix is a new versioned procedure or codeunit, a minimal identifier DTO, validation before firing, and explicit failure classification. See `version-business-events-and-keep-payloads-stable.bad.al`.

## See also

- `prefer-business-events-over-handwritten-retry-loops.md`
- `monitor-external-event-subscription-health.md`
- `send-an-idempotency-key-on-every-outbound-call.md`
