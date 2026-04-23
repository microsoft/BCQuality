---
bc-version: [all]
domain: privacy
keywords: [getlasterrortext, telemetry, callstack, dataclassification, pii]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Sanitize GetLastErrorText before sending to telemetry

## Description

`GetLastErrorText` and `GetLastErrorCallStack` return strings built from the failing call site's data — field values, record keys, customer names, filenames. Logging either to telemetry with `DataClassification::SystemMetadata` misstates the content: the actual values are CustomerContent or worse. The true classification is not always SystemMetadata, and silently mislabelling a CustomerContent payload as system data is the specific privacy regression to avoid.

## Best Practice

Log a generic error message and either omit GetLastErrorText entirely or classify the telemetry call as `DataClassification::CustomerContent`. Prefer `GetLastErrorText(false)` to exclude the call stack when the text is needed but the stack is not. When in doubt, log a generic summary and persist the detailed error separately in a restricted-access log the telemetry pipeline does not receive.

See sample: `sanitize-getlasterrortext-before-telemetry.good.al`.

## Anti Pattern

`Session.LogMessage(..., StrSubstNo('Operation failed: %1', GetLastErrorText(true)), ..., DataClassification::SystemMetadata, ...)` — the classification is wrong for the payload, and the call stack typically carries customer data from the failing operation into the telemetry stream.

See sample: `sanitize-getlasterrortext-before-telemetry.bad.al`.
