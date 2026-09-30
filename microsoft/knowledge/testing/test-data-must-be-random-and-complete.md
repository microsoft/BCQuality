---
bc-version: [all]
domain: testing
keywords: [testing, test-data, random, library, any]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Generate Test Data Programmatically, Never Assume Existing Records

> Contributions welcome — open a PR to refine or extend this article.

## Description

A BC test company normally contains initialized system/setup data — an AL test suite should not assume an empty database, but it must be independent of unrelated business records: create the records and setup it owns rather than looking up a specific code, number, or name assumed to already exist, since that makes the test fail for reasons unrelated to the code under test. Every mandatory field on a created record also needs an actual value — leaving one blank because setup-time validation happens to allow it produces a record that doesn't reflect a real one and can fail later, elsewhere in the flow (posting, a report, a later assertion), for a reason unrelated to what the test claims to check. A short-but-valid value is not itself a defect: AL field lengths are maxima, not minimums, so a two-character value in a `Text[100]` field is fine unless the scenario specifically depends on the field's length or shape — for example, a test that verifies truncation or a format check needs a value chosen to exercise that boundary, not an arbitrary short one.

Not every value should be generated, though. Incidental fixture data — identifiers, names, descriptions — should generally come from the standard library codeunits rather than be tied to specific existing data. But values that materially define the scenario under test — amounts, quantities, percentages, dates, thresholds, rounding precision — should stay explicit and deliberately chosen, not randomized: a rounding test needs values placed deliberately around the rounding boundary, not a random one that might miss it entirely.

## Best Practice

Use the standard library codeunits (`Library - ERM`, `Library - Inventory`, `Library - Sales`, `Library - Utility`) to generate incidental fixture values — they produce valid, unique-enough data via number series and controlled randomness, not a mathematical collision-free guarantee — and fill every mandatory field with correctly-sized data. Keep values that define the scenario's expected outcome explicit and fixed. Reserve hardcoded values for tests that validate an external contract itself — a fixed JSON schema, an EDIFACT message, a counterparty code — where the hardcoded value documents the specification rather than arbitrary test logic.

See sample: [`test-data-must-be-random-and-complete.good.al`](test-data-must-be-random-and-complete.good.al).

## Anti Pattern

Looking up a record assumed to already exist (a hardcoded payment method or customer number) instead of creating it, or leaving a mandatory field empty because setup-time validation happens to allow it. Also an anti-pattern, narrower: using a value that doesn't satisfy a scenario's explicit length or format requirement — for example a truncation test that never actually exceeds the field it's meant to overflow.

See sample: [`test-data-must-be-random-and-complete.bad.al`](test-data-must-be-random-and-complete.bad.al).
