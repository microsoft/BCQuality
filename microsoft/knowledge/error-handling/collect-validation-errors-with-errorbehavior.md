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

By default a procedure stops on the first `Error`, so a user fixing ten bad rows must rerun the operation ten times. The collectible-errors feature postpones error handling to the end of the call: a procedure attributed `[ErrorBehavior(ErrorBehavior::Collect)]` keeps running as collectible errors occur and gathers them, so all failures can be presented together. `GetCollectedErrors()` returns a `List of [ErrorInfo]` for the handler to inspect, but does not clear the collection by default; pass `true` to retrieve and clear in one call, or call `ClearCollectedErrors()` explicitly after retrieving. A handler can copy record information into a custom error page as Microsoft Learn demonstrates, or deliberately format only the messages into a final blocking error as this article's sample does.

## Best Practice

Mark the orchestrating procedure `[ErrorBehavior(ErrorBehavior::Collect)]` and run each item's validation so one failure doesn't abandon the rest — typically by calling the per-item routine through `Codeunit.Run`. When the run finishes, inspect `HasCollectedErrors()`, retrieve and clear the list with `GetCollectedErrors(true)`, and fail the operation with the collected messages. The sample intentionally produces a text aggregate and does not claim to retain record/field metadata in the final error. If that metadata is needed, map each `ErrorInfo` to a custom error UI before clearing, following the Microsoft Learn pattern. Do not replace validation failure with `Message`: clearing collected errors suppresses the platform failure, so the custom handler must still block the invalid operation.

See sample: `collect-validation-errors-with-errorbehavior.good.al`.

## Anti Pattern

Three shapes signal trouble. Hand-rolled accumulation reimplements collection and prevents the handler from receiving individual `ErrorInfo` values. A `Collect` procedure that never handles the collection falls back to the concatenated platform dialog. Finally, code that calls parameterless `GetCollectedErrors()`, assumes it cleared the list, and only shows a `Message` can both leave the errors collected and allow invalid processing to continue.

See sample: `collect-validation-errors-with-errorbehavior.bad.al`.
