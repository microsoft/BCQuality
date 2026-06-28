---
bc-version: [all]
domain: error-handling
keywords: [errorinfo, errortype, internal, client, telemetry, diagnostics, generic-message]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set ErrorInfo.ErrorType to Internal for defects you want in telemetry but not in the user's face

## Description

`ErrorInfo.ErrorType` controls where an error's message is shown. With `ErrorType::Client` — the behaviour of a normal `Error` — the message is both shown to the user and sent to telemetry. With `ErrorType::Internal` the user sees a generic message while the specific message you set is sent to telemetry only. The distinction matters for *unexpected* failures — a broken invariant, a failed internal assertion, a "this should never happen" branch — where the technical detail helps the partner diagnose the defect but would only confuse the end user. LLMs are unaware `ErrorType` exists, so they expose raw internal-failure text directly to users.

## Best Practice

Reserve `ErrorType::Internal` for errors the user cannot act on: corrupted internal state, an unreachable branch, a contract a caller violated. Set a precise, detail-rich `Message` and `DetailedMessage` for telemetry, raise it via `Error(ErrorInfo)`, and let the platform show the user a generic dialog. Keep `ErrorType::Client` (or a plain `Error`) for failures the user is expected to read and resolve — validation messages, missing setup, business-rule violations. The test is simple: if the message only makes sense to a developer, mark it `Internal`.

See sample: `errortype-internal-vs-client-for-diagnostics.good.al`.

## Anti Pattern

Raising an internal failure with a plain `Error('Unexpected state: ledger bucket %1 not initialized', BucketId)`. The user is shown a technical message they can do nothing about, and the signal is buried in a generic error rather than carried as structured telemetry detail. Detection: an `Error` whose wording targets a developer ("unexpected", "should not happen", raw internal identifiers) raised with default `Client` visibility instead of an `ErrorInfo` marked `ErrorType::Internal`.

See sample: `errortype-internal-vs-client-for-diagnostics.bad.al`.
