---
bc-version: [all]
domain: testing
keywords: [when, single-action, bdd, atdd, given-when-then, flow-test, regression-test]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep exactly one WHEN per test, with narrow exceptions for flow and defect-then-fix tests

## Description

Each test procedure should contain exactly one `[WHEN]` block: one action that triggers the behaviour under test. A test with multiple WHENs — "do A, then do B, then check C" — is two or more tests in disguise. Splitting them gives failure isolation (a failing test points at one action, not an ambiguous sequence) and keeps each test readable as a single, falsifiable claim. A precondition action, such as posting a document so a ledger entry exists to assert against, belongs in `[GIVEN]`; only the action actually being asserted belongs in `[WHEN]`.

## Best Practice

Give each test one `[WHEN]` and one focused claim. A procedure name containing "And" or "Then" in the middle (`GetPrice_AndDiscount_ReturnsValues`) is a strong signal the test should be split.

See sample: `test-one-when-per-test.good.al`.

## Anti Pattern

A test that performs a first action, then a second unrelated action, then asserts on both — mixing two falsifiable claims into one procedure so a failure can't tell you which action broke.

See sample: `test-one-when-per-test.bad.al`.

## Flow tests — a deliberate exception

A flow test verifies the accumulated outcome of a genuinely multi-round business process (partial receipt then invoicing, several posting rounds against one document), where the sequence itself is the scenario — splitting it would lose the interaction under test. Multiple `[WHEN]` blocks are allowed only when the procedure name declares the flow, each `[WHEN]` is labelled as one round of a single scenario rather than an unrelated action, and the `[THEN]` asserts the accumulated end-state rather than assertions that decompose cleanly per action (if they do decompose cleanly, it is still two tests in disguise). Outside this shape, unit-level tests keep the strict one-WHEN rule.

## Defect-then-fix tests — a second, narrower exception

A test that reproduces a specific broken state and then verifies a subsequent action corrects it is not the same shape as an unrelated-action test, even though its `[THEN]` assertions decompose cleanly per step — clean decomposition is expected here, not a sign of two unrelated tests. This shape is permitted only when the second `[WHEN]` cannot be meaningfully tested without the first (the fix only affects the exact stale state the first action produced, so splitting would just re-run the first action inside a second test's `[GIVEN]`), and the procedure name communicates the before/after relationship.
