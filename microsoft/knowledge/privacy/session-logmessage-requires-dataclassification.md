---
bc-version: [all]
domain: privacy
keywords: [session-logmessage, telemetry, data-classification, verbosity, telemetry-scope]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Every `Session.LogMessage` call must specify `DataClassification`

## Description

`Session.LogMessage` writes a record to the telemetry pipeline. The platform requires the call to carry an explicit `DataClassification` argument so that the entry can be routed and retained correctly downstream — telemetry consumers, GDPR exports, and Application Insights dashboards all rely on it. The compiler accepts overloads without the parameter (the two-argument and three-argument shapes that omit it), but for any telemetry that ships to customers, the `DataClassification`-bearing overload is the correct one.

## Best Practice

Use the overload that takes `Verbosity`, `DataClassification`, and `TelemetryScope`. For payload-free operational telemetry that does not embed customer data, `DataClassification::SystemMetadata` is the right value. Choose `TelemetryScope::ExtensionPublisher` for telemetry meant for the publishing partner only; `TelemetryScope::All` also forwards to the customer's tenant telemetry.

See sample: [`session-logmessage-requires-dataclassification.good.al`](session-logmessage-requires-dataclassification.good.al).

## Anti Pattern

Calling `Session.LogMessage('0003', 'Operation completed', Verbosity::Normal)` — the overload omits `DataClassification` and leaves the platform without the information needed to classify the entry. Detection signal: a `Session.LogMessage` call whose argument list ends at `Verbosity`.

See sample: [`session-logmessage-requires-dataclassification.bad.al`](session-logmessage-requires-dataclassification.bad.al).
