---
bc-version: [17..]
domain: telemetry
keywords: [telemetryscope, extensionpublisher, all, audience, logmessage, application-insights]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Choose TelemetryScope by who must receive the signal

## Description

`TelemetryScope::ExtensionPublisher` sends a custom trace only to the Application Insights resource configured by the extension publisher. `TelemetryScope::All` also sends it to the environment's telemetry, where the customer or partner operating the tenant can query it. The compiler accepts either value, so a plausible-looking scope can silently hide an actionable signal from tenant operators or expose publisher-only implementation noise to them.

## Best Practice

Use `ExtensionPublisher` for internal diagnostics that only the app publisher can interpret, such as cache behavior or private algorithm state. Use `All` for signals the tenant operator can act on, such as an integration failure, quota warning, or setup problem. Decide the audience independently from `DataClassification`; privacy guidance still governs whether the payload may be emitted at all.

See sample: `choose-telemetry-scope-by-audience.good.al`.

## Anti Pattern

Defaulting every call to `All`, including low-level implementation diagnostics, or defaulting every call to `ExtensionPublisher` and thereby hiding customer-actionable failures from environment telemetry. Review only when the message and surrounding branch make the intended audience clear; an ambiguous diagnostic is not enough to infer the wrong scope.

See sample: `choose-telemetry-scope-by-audience.bad.al`.
