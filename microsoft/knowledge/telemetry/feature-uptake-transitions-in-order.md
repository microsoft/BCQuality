---
bc-version: [18..]
domain: telemetry
keywords: [featuretelemetry, loguptake, discovered, set-up, used, uptake-status, lifecycle]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Emit FeatureTelemetry uptake states in lifecycle order

## Description

`FeatureTelemetry.LogUptake` accepts `Discovered`, `Set up`, `Used`, and `Undiscovered`, but the platform records the forward transition only as `Discovered` to `Set up` to `Used`. If the first call for a feature is `Set up` or `Used`, no uptake telemetry is emitted. `Undiscovered` is the explicit reset from any state.

## Best Practice

Log `Discovered` when the user encounters the feature, `Set up` after its setup is completed, and `Used` when the user attempts it. Keep the same feature name throughout the funnel. Review ordering only when the changed repository context shows the feature's lifecycle; a single isolated `Used` call cannot prove that earlier states are absent elsewhere.

See sample: `feature-uptake-transitions-in-order.good.al`.

## Anti Pattern

Introducing a feature whose only uptake call jumps directly to `Set up` or `Used`, or using different feature-name literals for successive states. The calls compile and run, but the funnel silently omits the invalid transition.

See sample: `feature-uptake-transitions-in-order.bad.al`.
