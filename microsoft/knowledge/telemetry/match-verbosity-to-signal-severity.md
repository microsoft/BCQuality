---
bc-version: [17..]
domain: telemetry
keywords: [verbosity, severitylevel, critical, error, warning, normal, verbose, logmessage]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Match telemetry Verbosity to the signal's actual severity

## Description

`Verbosity` becomes the Application Insights `severityLevel` and participates in on-premises diagnostic trace filtering. `Critical` represents abnormal termination, `Error` a severe error, `Warning` a warning, `Normal` a non-error event, and `Verbose` detailed tracing. Logging a caught failure as `Normal` is not cosmetic: severity-based alerts miss it, and an on-premises service configured to emit only warnings and above can drop it completely.

## Best Practice

Use `Error` for failed operations that need investigation and `Critical` only for abnormal termination or equivalent loss of service. Use `Warning` for degraded but completed behavior, `Normal` for successful business events, and `Verbose` for detailed diagnostics. Judge the outcome, not the procedure name: an expected optional lookup miss can legitimately remain `Normal` or `Verbose`.

See sample: `match-verbosity-to-signal-severity.good.al`.

## Anti Pattern

A `Session.LogMessage` in a failed `TryFunction`, failed `Codeunit.Run`, unsuccessful HTTP response, or other explicit failure branch that uses `Verbosity::Normal` or `Verbose` without evidence that the failure is expected and benign.

See sample: `match-verbosity-to-signal-severity.bad.al`.
