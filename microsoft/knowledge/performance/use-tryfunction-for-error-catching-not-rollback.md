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

`[TryFunction]` annotates a method so that errors raised inside it can be caught by the caller instead of propagating. Per the platform reference, "changes to the database that are made with a try method aren't rolled back" — the attribute catches the error; it does not unwind database state. This is the critical distinction from `Codeunit.Run`, which does roll back on error (see `codeunit-run-as-atomic-sub-operation.md`). A try function also only catches when its return value is used: "If the return variable for a call to a function, which is attributed with [TryFunction] isn't used, then the call isn't considered a try function call." `DoTry();` propagates errors normally; only `ok := DoTry();` or `if DoTry() then ...` catches. The return type is forced to Boolean; user-defined return types are not allowed, and the value isn't accessible inside the try method itself. On Business Central on-premises, writes inside a try method are blocked by default and raise a runtime error unless `DisableWriteInsideTryFunctions` is set to `false` on the server — SaaS has no such restriction.

## Best Practice

Reach for `[TryFunction]` when you want to catch a failure without unwinding the transaction — HTTP calls whose non-2xx responses should surface a user-friendly message, .NET interop whose exceptions you want to translate, validation or parsing routines whose errors you intend to log and continue past. Always capture the return: `if MyTry() then ... else HandleFailure(GetLastErrorText());`. When the work is transactional — writes that must either fully apply or fully revert — use `Codeunit.Run` instead. The two primitives solve different problems: one catches errors, the other bounds a rollback scope.

Use `[TryFunction]` sparingly. Each caught error writes to the session-wide `GetLastErrorText` and `GetLastErrorCallStack` buffers, and every subsequent catch overwrites the earlier state — a helper that reads `GetLastErrorText` later may see a different error than the one it intended to inspect. Prefer explicit checks (non-throwing predicates, guard conditions, upfront validation) for operations with predictable failure modes; reserve `[TryFunction]` for genuinely unpredictable failures such as network calls, third-party interop, or evaluation of user-supplied expressions. When you do catch, read `GetLastErrorText` immediately after the failed call, and call `ClearLastError` before the call if an earlier catch in the same scope could have left state behind — per the platform reference, "If you call the GetLastErrorText method immediately after you call the ClearLastError method, then an empty string is returned."

See sample: `use-tryfunction-for-error-catching-not-rollback.good.al`.

## Anti Pattern

Wrapping database writes in `[TryFunction]` expecting the writes to roll back when the method errors. They do not: the writes that succeeded before the error remain, the caller receives `false`, and the corrupted-state bug surfaces in production. A related anti-pattern is calling a try function without capturing the return (`DoTry();`), which silently strips the error-catching behavior and lets the error propagate — the code looks defensive but behaves identically to an unwrapped call. A third is defensive sprinkling: wrapping every operation that *could* theoretically error in `[TryFunction]` on the theory that catching is always safer than propagating. Each extra catch pollutes the shared error buffer and makes the diagnostic signal harder to find when something real does fail.

See sample: `use-tryfunction-for-error-catching-not-rollback.bad.al`.
