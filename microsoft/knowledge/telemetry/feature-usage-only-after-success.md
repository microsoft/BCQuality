---
bc-version: [18..]
domain: telemetry
keywords: [featuretelemetry, logusage, logerror, success, tryfunction, feature-usage]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Call FeatureTelemetry.LogUsage only after successful use

## Description

`FeatureTelemetry.LogUsage` means that a user successfully used the feature. An attempt belongs in the uptake funnel, while a failed operation belongs in `LogError`. Logging usage before checking the result inflates adoption metrics with failed attempts and makes usage telemetry disagree with the actual business outcome.

## Best Practice

Call `LogUsage` only after the operation has completed successfully. On a failure path, call `LogError` with the captured error text and call stack when the failure must be emitted explicitly. Use a past-tense event name for usage and a present-tense scenario name for errors.

See sample: `feature-usage-only-after-success.good.al`.

## Anti Pattern

Calling `LogUsage` before a Boolean result, `TryFunction`, `Codeunit.Run`, or HTTP status has been checked, or calling it in both success and failure branches. Do not flag an attempt recorded with `LogUptake(...Used)`; unlike `LogUsage`, that state intentionally records an attempt.

See sample: `feature-usage-only-after-success.bad.al`.
