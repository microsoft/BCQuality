---
bc-version: [all]
domain: testing
keywords: [test, refactor, adapt, existing-code, green, failing, tdd]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

When a CURABIS developer asks for a test that "must work" or "must pass",
the agent's job is to write a test that passes against the **existing production code**
— not to write an idealized test and then report that the code needs changing.

This rule applies in two distinct scenarios:

**Scenario A — New test for existing behaviour**
The production code is correct and stable. Write the test to match what the code
actually does. Read the relevant codeunits before writing assertions. If the
expected value in the story differs from what the code produces, surface the
discrepancy and ask before assuming either is wrong.

**Scenario B — Refactoring an existing test**
The test exists but fails because the production code was changed. Adapt the
test to match the new behaviour. Do not rewrite the production code to make
the old test pass unless explicitly asked to refactor production code.

## The distinction that matters

Writing a test that adapts to existing code is **not** the same as writing a
test that accepts wrong behaviour silently. If the production code contains a
bug that contradicts the business specification, flag it explicitly:

```
// ⚠️ NOTE: This assertion reflects current code behaviour.
// Business spec says 1792,00 but code currently produces 1800,00.
// Flagged for review — do not merge until resolved.
```

Never silently adjust an assertion to make a test green when the discrepancy
is a real business logic error.

## Anti Pattern

```al
// WRONG: Writing the "ideal" test without reading the production code,
// then leaving it failing and saying "the code needs to be fixed"
[THEN]
Assert.AreEqual(1792, ActualAmount, 'Total should be 1792');
// Test fails. Agent says: "You need to fix SVPost to produce 1792."
// This is not what was asked for.
```

## Best Practice

```al
// CORRECT: Read SVPost, understand what it produces, write the test to match.
// If the number is 1792 in both spec and code → assert 1792.
// If the number differs → flag it, don't silently change it.

// [GIVEN] Read SVPost.Codeunit.al and SV Test Library before writing assertions.
// [THEN] Assert what the code actually produces, verified by reading the source.
Assert.AreEqual(ExpectedAmount, ActualAmount, 'Net payout to vendor must match');
```

## Workflow when asked to write a passing test

1. Read the relevant production codeunits (SVPost, SVApplyMgt, etc.)
2. Trace the calculation path for the specific scenario
3. Derive the expected values from the code — not only from the story
4. If code and story agree → write the test with those values
5. If code and story disagree → write the test with the code's values AND add
   a clearly visible `// ⚠️ NOTE` comment explaining the discrepancy
6. Never leave a test failing when the task was to write a passing test
