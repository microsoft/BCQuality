---
bc-version: [all]
domain: performance
keywords: [try-function, try-method, error-handling, rollback, atomic, exception, get-last-error, session-buffer]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use [TryFunction] for error catching, Codeunit.Run for atomic rollback

## Description

`[TryFunction]` lets a caller catch an error, but database changes made before that error are not rolled back. The attribute catches; it does not unwind transaction state. This is the critical distinction from `Codeunit.Run`, which can provide an atomic rollback boundary (see `codeunit-run-as-atomic-sub-operation.md`). On Business Central on-premises, writes inside a try method are blocked by default unless `DisableWriteInsideTryFunctions` is set to `false`; SaaS does not provide that server setting.

## Best Practice

Reach for `[TryFunction]` when you want to catch a failure without unwinding the transaction — for example, third-party interop or parsing whose error you intend to translate. When writes must either fully apply or fully revert, use `Codeunit.Run` instead. The two primitives solve different problems: one catches errors, the other bounds a rollback scope.

Use `[TryFunction]` sparingly. Each caught error writes to the session-wide `GetLastErrorText` and `GetLastErrorCallStack` buffers, and every subsequent catch overwrites the earlier state — a helper that reads `GetLastErrorText` later may see a different error than the one it intended to inspect. Prefer explicit checks (non-throwing predicates, guard conditions, upfront validation) for operations with predictable failure modes; reserve `[TryFunction]` for genuinely unpredictable failures such as network calls, third-party interop, or evaluation of user-supplied expressions. When you do catch, read `GetLastErrorText` immediately after the failed call, and call `ClearLastError` before the call if an earlier catch in the same scope could have left state behind — per the platform reference, "If you call the GetLastErrorText method immediately after you call the ClearLastError method, then an empty string is returned."

See sample: `use-tryfunction-for-error-catching-not-rollback.good.al`.

## Anti Pattern

Wrapping database writes in `[TryFunction]` and expecting successful writes before the error to roll back. They remain, the caller receives `false`, and partially applied state can escape. Defensive sprinkling is also unsafe: every catch overwrites the session error buffer and can hide the failure a later helper intended to inspect.

See sample: `use-tryfunction-for-error-catching-not-rollback.bad.al`.

## See also

`microsoft/knowledge/error-handling/ignored-tryfunction-return-disables-try-semantics.md` owns the separate call-site rule that a try method's Boolean result must be consumed.
