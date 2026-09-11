---
bc-version: [all]
domain: privacy
keywords: [feature-telemetry, customdimensions, logusage, loguptake, logerror, pii, euii, eupi]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `FeatureTelemetry` `CustomDimensions` follow the same privacy rules as `Session.LogMessage`

## Description

`Codeunit "Feature Telemetry"` is the second telemetry surface in AL. Its methods — `LogUsage()`, `LogUptake()` and `LogError()` — each accept a `CustomDimensions` dictionary parameter whose contents are sent to telemetry as-is. The platform does not classify per-dimension values for you, so any customer or employee data placed into the dictionary is logged verbatim. The privacy rules that apply to `Session.LogMessage` message text apply to every value in `CustomDimensions`: no customer or employee names, email addresses, phone numbers (`CustomerContent`/EUII); no employee codes, user IDs or user security IDs (EUPI); no user-provided content (addresses, descriptions, notes); no `GetLastErrorText()` output.

## Best Practice

Pass only non-personal context through `CustomDimensions` — feature names, status enums, counts, error codes, durations. For uptake or usage signals that do not need per-call context, prefer the parameterless overload of `LogUptake`/`LogUsage` over a `CustomDimensions` dictionary that risks accreting PII over time.

See sample: [`featuretelemetry-customdimensions-no-pii.good.al`](featuretelemetry-customdimensions-no-pii.good.al).

## Anti Pattern

`CustomDimensions.Add('EmployeeNo', ExpenseHeader."Employee No.")` followed by `FeatureTelemetry.LogUsage(...)` — the employee number is a pseudonymous user identifier (EUPI) and is now in telemetry. Same pattern with `'UserName'`, `'CustomerEmail'`, `'AttachmentName'` etc.

See sample: [`featuretelemetry-customdimensions-no-pii.bad.al`](featuretelemetry-customdimensions-no-pii.bad.al).
