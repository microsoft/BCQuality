---
bc-version: [all]
domain: error-handling
keywords: [collectible-errors, errorbehavior, collect, getcollectederrors, hascollectederrors, validation, batch]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Collect validation errors with ErrorBehavior::Collect and handle the collected list

## Description

By default a procedure stops on the first `Error`, so a user fixing ten bad rows must rerun the operation ten times. The collectible-errors feature postpones error handling to the end of the call: a procedure attributed `[ErrorBehavior(ErrorBehavior::Collect)]` keeps running as errors occur and gathers them, so all failures can be presented together. The collected errors are read with `HasCollectedErrors()` and `GetCollectedErrors()` (which returns a `List of [ErrorInfo]`); `ClearCollectedErrors()` empties the buffer. This is a platform mechanism most LLMs are unaware of — they reach for a manually concatenated `Text` buffer or a temporary error table instead.

## Best Practice

Mark the orchestrating procedure `[ErrorBehavior(ErrorBehavior::Collect)]` and run each item's validation so one failure doesn't abandon the rest — typically by calling the per-item routine through `Codeunit.Run`. When the run finishes, inspect `HasCollectedErrors()` and surface `GetCollectedErrors()` to the user as a single list. Always handle the collected errors yourself: the platform's own guidance is that any errors still in the collected list when the procedure ends are concatenated into one dialog, which is hard for users to read.

See sample: `collect-validation-errors-with-errorbehavior.good.al`.

## Anti Pattern

Two shapes signal trouble. The first is hand-rolled accumulation — appending messages to a `Text` variable and showing them at the end — which reimplements the platform feature, loses each error's `ErrorInfo` structure, and skips telemetry classification. The second is applying `[ErrorBehavior(ErrorBehavior::Collect)]` but never calling `HasCollectedErrors`/`GetCollectedErrors`, so every collected error spills into the platform's concatenated end-of-procedure dialog. Detection: a `Collect` attribute with no matching `GetCollectedErrors` call, or a per-row loop that builds an error string by concatenation.

See sample: `collect-validation-errors-with-errorbehavior.bad.al`.
