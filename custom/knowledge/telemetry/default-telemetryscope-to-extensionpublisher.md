---
bc-version: [all]
domain: telemetry
keywords: [telemetry, session-logmessage, telemetryscope, application-insights, extensionpublisher, ingestion-cost]
technologies: [al]
countries: [w1]
application-area: [all]
extends: community/telemetry/default-telemetryscope-to-extensionpublisher.md
---
# Default TelemetryScope to ExtensionPublisher, not All

> Contributions welcome — open a PR to refine or extend this article.

## Description
The `TelemetryScope` parameter of `Session.LogMessage` (and `LogError`) controls *where* a custom telemetry signal is routed, not just whether it is emitted. `TelemetryScope::ExtensionPublisher` sends the signal only to the extension publisher's own Application Insights resource. `TelemetryScope::All` sends it to **both** the publisher's resource **and** the customer's environment-level Application Insights resource. The distinction is easy to get wrong because both values compile and both "emit telemetry" — but `All` silently adds to the customer's ingestion volume and cost. Promoted to always-on: CURABIS builds telemetry-based health checks across customer environments (Wareco, Allnet, Guardique), so a scope mistake here doesn't just cost the customer — it pollutes the very signal CURABIS's own tooling reads.

## Best Practice
Default to `TelemetryScope::ExtensionPublisher` for diagnostic telemetry that only the publisher acts on. Reserve `TelemetryScope::All` for signals the customer's own administrators are expected to monitor and act on (for example, a business event surfaced to their environment telemetry). Treat the choice as a deliberate routing decision per signal, not a copy-paste default.

## Anti Pattern
Emitting all custom telemetry with `TelemetryScope::All` "to be safe." This pushes the publisher's internal diagnostics into every customer's Application Insights, inflating their ingestion cost and burying their own signals in noise — a footgun a code reviewer can catch by flagging `All` on any signal the customer would not act on.
