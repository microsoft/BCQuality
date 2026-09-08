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

## Source

Drawn from Luc van Vugt's "TDD in NAV – ASSERTERROR or IsFalse": https://www.fluxxus.nl/index.php/bc/tdd-in-nav-asserterror-or-isfalse/. The post's own example and reasoning — reserve `asserterror` for the product code actually raising an error, use `Assert.IsFalse`/`Assert.IsTrue` to check a boolean the test framework itself computes — carries over directly; the overlap with `asserterror-needs-expectederror-and-code.md` below is this repository's own addition, not from the source.

## Scope

This rule and `asserterror-needs-expectederror-and-code.md` can both match `asserterror Assert.IsTrue(SomeFunc(), Msg);` with nothing after it — the generic rule sees a bare `asserterror`, this one sees `asserterror` wrapping an `Assert.IsTrue`/`Assert.IsFalse` call used to invert a boolean. This rule wins for that shape: the fix is to replace the construct with a direct `Assert.IsFalse`/`Assert.IsTrue` call, not to add `Assert.ExpectedError`/`Assert.ExpectedErrorCode` after it. `asserterror-needs-expectederror-and-code.md` still applies on its own to every other bare `asserterror`, including one guarding `Assert.IsTrue`/`Assert.IsFalse` where the intent genuinely is to assert that the guarded call itself raises an error (for example, asserting that a validation helper errors before it can even return a boolean).
