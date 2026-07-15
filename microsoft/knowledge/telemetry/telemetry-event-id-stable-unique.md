---
bc-version: [17..]
domain: telemetry
keywords: [telemetry, logmessage, event-id, sessionlogmessage, observability]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Telemetry event IDs must be stable, unique, and non-placeholder

## Description

The first parameter of `Session.LogMessage` is the **event ID**. Telemetry consumers — Application Insights queries, KQL dashboards, alert rules, support runbooks — pivot on this ID to filter and aggregate events. The contract works only when the ID is:

- **Stable** across releases: the same logical event keeps the same ID, so existing queries continue to match it.
- **Unique** within the extension's telemetry catalogue: two different events MUST NOT share an ID, or downstream consumers cannot distinguish them.
- **Non-placeholder**: literal IDs like `'0000'`, `'1234'`, `'TODO'`, or `'XX0000'` are placeholders that collide with other placeholder-using extensions, are unsearchable, and indicate the catalogue entry was never registered.

The convention used by Microsoft first-party AL code is a short prefix identifying the publisher or feature followed by a numeric suffix — for example `'AL0001'`, `'CUST0042'`, `'SHPFY-0007'`. The exact format is up to the extension; the requirements are stability, uniqueness, and that the chosen ID is registered in whatever catalogue or wiki the extension's telemetry consumers reference.

## Best Practice

Assign each `Session.LogMessage` call a real, registered event ID drawn from the extension's catalogue. Treat the ID as part of the public contract of the event — renaming it is a breaking change for consumers. Keep IDs short, deterministic, and free of personal or environment-specific tokens.

See sample: `telemetry-event-id-stable-unique.good.al`.

## Anti Pattern

Calling `Session.LogMessage('0000', ...)` (or `'1234'`, `'TODO'`, an empty string, a GUID generated at runtime, or any other placeholder) leaves the event unsearchable and indistinguishable from every other event using the same placeholder. The catalogue entry never gets created because the developer "will fix it later", and the placeholder ships.

See sample: `telemetry-event-id-stable-unique.bad.al`.
