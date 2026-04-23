---
bc-version: [all]
domain: privacy
keywords: [telemetry, session-logmessage, dataclassification, dimensions, pii]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Specify DataClassification on every telemetry call and keep PII out of the message

## Description

`Session.LogMessage` accepts a DataClassification parameter that governs how the platform handles the logged content in the telemetry pipeline. Omitting it is a schema violation the platform cannot repair later. Embedding personal data — emails, names, phone numbers, addresses, filenames of user uploads — in the message string also defeats classification, because the pipeline sees opaque text and cannot selectively redact.

## Best Practice

Pass DataClassification explicitly on every Session.LogMessage call. Keep the message a generic, non-identifying sentence and place structured values in custom dimensions where the classification applies per key. Business identifiers (Customer No., Document No., Vendor No.) are acceptable as dimensions; free-text personal data is not.

See sample: `specify-dataclassification-on-every-telemetry-call.good.al`.

## Anti Pattern

`Session.LogMessage('0001', StrSubstNo('Customer %1 processed', Customer.Name), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All)` — the declared classification is SystemMetadata but the message carries CustomerContent. The payload is logged with the wrong tag; downstream consumers treat it as safe when it is not.

See sample: `specify-dataclassification-on-every-telemetry-call.bad.al`.
