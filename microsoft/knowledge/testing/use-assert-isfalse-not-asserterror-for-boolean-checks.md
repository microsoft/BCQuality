---
bc-version: [all]
domain: testing
keywords: [assert, isfalse, istrue, asserterror, boolean-check, negative-test]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use Assert.IsFalse to check a boolean result, not asserterror around Assert.IsTrue

## Description

`asserterror` exists to assert that a statement raises a runtime error; it is not a general-purpose way to invert a boolean check. Wrapping `asserterror Assert.IsTrue(SomeFunc(), Msg)` to verify that `SomeFunc()` returns `false` tests whether `Assert.IsTrue`'s own error-raising behavior fired, not the value `SomeFunc()` actually returned.

## Best Practice

When the code under test returns a `Boolean` rather than raising an error, assert the value directly with `Assert.IsFalse(SomeFunc(), Msg)` (or `Assert.IsTrue` for the positive case). Reserve `asserterror` for statements expected to actually raise an error.

See sample: `use-assert-isfalse-not-asserterror-for-boolean-checks.good.al`.

## Anti Pattern

`asserterror Assert.IsTrue(SomeFunc(), Msg);` to verify `SomeFunc()` is `false`. It passes today because `Assert.IsTrue` happens to raise an error on failure, but it verifies the assertion helper's error-raising behavior, not the value under test.

See sample: `use-assert-isfalse-not-asserterror-for-boolean-checks.bad.al`.
