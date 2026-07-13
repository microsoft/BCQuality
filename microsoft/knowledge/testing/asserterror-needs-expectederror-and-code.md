---
bc-version: [all]
domain: testing
keywords: [asserterror, expectederror, expectederrorcode, negative-test, error-code]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pin asserterror to a specific error with ExpectedError and ExpectedErrorCode

## Description

`asserterror` passes when the guarded statement raises any error at all. That is too permissive for a negative test: a typo, a missing setup record, or a permission failure all raise errors, so a bare `asserterror` can go green while never exercising the rule it claims to verify — false confidence that the validation works. Constrain it. `Assert.ExpectedError(text)` checks the message of the error that was actually raised, and `Assert.ExpectedErrorCode(code)` checks its error code. Together they assert that the specific failure occurred, turning "something went wrong" into "the right thing went wrong for the right reason".

## Best Practice

Follow every `asserterror` with a verification of the error it expects, and prefer the reusable `Library Assert` helpers over hardcoded literals. For a mandatory-field check, `Assert.ExpectedTestFieldError(FieldCaption, ExpectedValue)` encapsulates both the message and the `TestField` code, so the test survives caption or code changes and does not repeat that knowledge in every method. For other errors, pair `Assert.ExpectedError` with a stable substring — ideally a shared `Label`, not an inline sentence — and, where known, `Assert.ExpectedErrorCode`. When a needed check is missing from the shared library, extend `Library Assert` (or your own assert library) with a helper rather than hardcoding message text and codes across tests; matching on a code or an invariant fragment keeps the test from going blind to the wrong error when a caption is localized.

See sample: `asserterror-needs-expectederror-and-code.good.al`.

## Anti Pattern

`asserterror DoInvalid();` with nothing after it. The test asserts only that the call failed somehow; swap the validation for a different bug and the test still passes, certifying a guard that may no longer fire. A negative test that cannot tell one error from another verifies almost nothing.

See sample: `asserterror-needs-expectederror-and-code.bad.al`.
