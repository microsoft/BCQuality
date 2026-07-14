---
bc-version: [18..]
domain: privacy
keywords: [featuretelemetry, logerror, errortext, errorcallstack, alerrortext, alerrorcallstack, customdimensions]
technologies: [al]
countries: [w1]
application-area: [all]
---

# FeatureTelemetry.LogError emits more than caller custom dimensions

## Description

`FeatureTelemetry.LogError` emits its `ErrorText` as the telemetry message and adds it as `alErrorText`. The overloads with `ErrorCallStack` also add `alErrorCallStack`. These dimensions are produced in addition to the caller-supplied `CustomDimensions` dictionary, and the Feature Telemetry implementation sends the event as `SystemMetadata`.

## Best Practice

Review the dedicated error arguments as telemetry payload. Capture `GetLastErrorText(true)` when scrubbed platform error text is sufficient, and pass `GetLastErrorCallStack()` only as a call stack. Keep custom dimensions non-personal too.

See sample: `featuretelemetry-logerror-implicit-errortext.good.al`.

## Anti Pattern

Approving a `LogError` call because its explicit dictionary contains only safe values while it passes unsanitized `GetLastErrorText()` or arbitrary context through `ErrorText` or `ErrorCallStack`. Those arguments become telemetry dimensions outside the dictionary.

See sample: `featuretelemetry-logerror-implicit-errortext.bad.al`.
