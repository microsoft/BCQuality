---
bc-version: [19..]
domain: error-handling
keywords: [collectible-errors, errorbehavior, collect, getcollectederrors, hascollectederrors, validation, batch]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Collect validation errors with ErrorBehavior::Collect and handle the collected list

## Description

By default a procedure stops on the first `Error`, so a user fixing ten bad rows must rerun the operation ten times. The collectible-errors feature postpones error handling to the end of the call: a procedure attributed `[ErrorBehavior(ErrorBehavior::Collect)]` keeps running as errors occur and gathers them, so all failures can be presented together. `GetCollectedErrors()` returns a `List of [ErrorInfo]` but does not clear the collection by default; pass `true` to retrieve and clear in one call, or call `ClearCollectedErrors()` explicitly after retrieving. This is a platform mechanism most LLMs are unaware of — they reach for a manually concatenated `Text` buffer or a temporary error table instead.

## Best Practice

Mark the orchestrating procedure `[ErrorBehavior(ErrorBehavior::Collect)]` and run each item's validation so one failure doesn't abandon the rest — typically by calling the per-item routine through `Codeunit.Run`. When the run finishes, inspect `HasCollectedErrors()`, retrieve and clear the list with `GetCollectedErrors(true)`, and fail the operation with the collected validation details. Do not replace validation failure with `Message`: clearing collected errors suppresses the platform failure, so the custom handler must still block the invalid operation.

See sample: `collect-validation-errors-with-errorbehavior.good.al`.

## Anti Pattern

Three shapes signal trouble. Hand-rolled accumulation reimplements the platform feature and loses each error's `ErrorInfo` structure. A `Collect` procedure that never handles the collection falls back to the concatenated platform dialog. Finally, code that calls parameterless `GetCollectedErrors()`, assumes it cleared the list, and only shows a `Message` can both leave the errors collected and allow invalid processing to continue.

See sample: `collect-validation-errors-with-errorbehavior.bad.al`.
