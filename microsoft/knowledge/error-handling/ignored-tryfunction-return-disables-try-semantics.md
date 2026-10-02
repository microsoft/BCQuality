---
bc-version: [13..]
domain: error-handling
keywords: [tryfunction, try-method, boolean-return, ignored-return-value, error-propagation, dead-failure-branch]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Consume a TryFunction return value when the caller handles the failure

## Description

A `[TryFunction]` catches errors only when the caller uses its Boolean return value. An assignment or conditional makes the invocation a try-method call; a bare call is treated as an ordinary procedure call and exposes errors as usual. The attribute alone does not make every invocation non-throwing, so code that handles the failure of a bare call never sees that failure: the error leaves the procedure before the handling runs.

## Best Practice

When the caller must continue, log, count, or translate the failure, consume the result directly: assign it to a Boolean or use the call in an `if` condition. Handle `false` immediately while the last-error state still describes that failure.

When the error should simply propagate, a bare call is correct and needs no change; see `microsoft/knowledge/error-handling/bare-tryfunction-call-propagates-errors.md`.

See sample: [`ignored-tryfunction-return-disables-try-semantics.good.al`](ignored-tryfunction-return-disables-try-semantics.good.al).

## Anti Pattern

Calling a `[TryFunction]` procedure as a standalone statement while the surrounding code expects the failure to be caught. Detect it from code, not from the call shape alone: the bare call is followed by a `GetLastErrorText`, `GetLastErrorCode`, or `GetLastErrorObject` check, a failure branch, failure logging, or a `false`/failure result; or it sits in a loop that is meant to continue past failed items. None of that handling sees the call's error, because the error stops the procedure first.

A bare call with no such handling is intended propagation, not this anti-pattern.

See sample: [`ignored-tryfunction-return-disables-try-semantics.bad.al`](ignored-tryfunction-return-disables-try-semantics.bad.al).

## See also

`microsoft/knowledge/performance/use-tryfunction-for-error-catching-not-rollback.md` owns transaction rollback expectations after a try method has actually caught an error.

## References

- [Handling errors using try methods](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-handling-errors-using-try-methods): "If a try method call uses the return value in an `OK:=` statement or a conditional statement such as `if-then`, errors are caught."
