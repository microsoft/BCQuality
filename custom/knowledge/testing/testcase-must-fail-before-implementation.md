---
bc-version: [all]
domain: testing
keywords: [tdd, red-green, test-first, testcase, verification, human-checkpoint, lifecycle]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Test case must fail before implementation begins

## Description

Every task starts with a test case, and the test case must **demonstrably
fail (red)** — verified by the developer, not self-certified by the AI —
before implementation begins. The task may only be completed when the same
test case **passes (green)**.

The lifecycle gate, in order:

1. Task started (branch + BC status — see `[[one-task-in-progress-at-a-time]]`)
2. Test case written for the requirement — including any fields, setup
   objects, or test data structures the scenario needs that do not yet exist
3. Test is run; **the developer verifies the red result** — an AI session
   must never assert "the test fails" without a run the developer has seen
4. Implementation begins
5. Test is run again; **green is a precondition for finishing the task** —
   no merge to the track branch, no BC `Done`, while the test case is red

## Why

A test written after the code proves only that the code does what the code
does. A test that was red first proves two separate things: that the test
actually exercises the requirement (red = the gap is real), and later that
the requirement is met (green = the gap is closed). The human verification
of red is the cheap insurance: thirty seconds of looking at a failing test
catches the test that accidentally passes vacuously — the most dangerous
test in any suite.

## Anti Pattern

    // Implementation written first, test added afterwards to "cover" it.
    // Test passes on first run — it has never been observed red.
    // Nobody knows whether it tests the requirement or just the code.

## Best Practice

    // [GIVEN] a customer with a tier-price agreement
    // [WHEN] FindPrice is called for quantity 100        (test-one-when-per-test)
    // [THEN] the tier price is returned, not the unit price
    //
    // Run 1 (before implementation): FAILS — developer confirms red ✓
    // ... implementation ...
    // Run 2: PASSES — task may now be completed ✓

Test structure follows the existing testing rules:
`[[test-one-when-per-test]]`, `[[test-setup-must-use-library-codeunit]]`,
`[[test-data-must-be-random-and-complete]]`, `[[test-feature-scenario-tags]]`.

## Scope

All CURABIS repositories — customer apps and AppSource apps alike. Applies to
every task that changes behavior. Pure refactorings keep existing tests green
throughout; documentation/translation tasks are exempt.
