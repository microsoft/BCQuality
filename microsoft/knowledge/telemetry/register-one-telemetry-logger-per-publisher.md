---
bc-version: [18..]
domain: telemetry
keywords: [telemetry-logger, interface, register, publisher, featuretelemetry, onregistertelemetrylogger]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Register exactly one Telemetry Logger implementation per publisher

## Description

The `Telemetry` and `Feature Telemetry` codeunits reach an extension publisher's telemetry through an implementation of the `"Telemetry Logger"` interface registered with `"Telemetry Loggers".OnRegisterTelemetryLogger`. The platform requires exactly one registration per app publisher. No registration prevents the module from working as expected; multiple registrations make the destination ambiguous and produce platform error telemetry.

## Best Practice

Place one internal logger implementation in one app for the publisher, forward its `LogMessage` method to `Session.LogMessage`, and register it from one event subscriber. Companion apps with the same publisher reuse that registration instead of each adding another. Evaluate absence only with repository or app-family context; a single-file diff cannot prove that no logger exists elsewhere.

See sample: `register-one-telemetry-logger-per-publisher.good.al`.

## Anti Pattern

Adding `FeatureTelemetry` calls to a complete app with no logger registration, or registering two logger implementations for apps that share the same publisher. The calls compile, but the telemetry module reports the missing or duplicate registration instead of behaving as intended.

See sample: `register-one-telemetry-logger-per-publisher.bad.al`.
