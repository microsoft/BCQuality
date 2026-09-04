---
bc-version: [all]
domain: testing
keywords: [given, test-setup, posting, report, request-page, precondition, completeness]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Cover the full precondition chain in GIVEN, not just the primary record

## Description

A `[GIVEN]` block is only correct if it sets up every precondition the code under test actually reads, not just the record the scenario is "about." For most master-data tests, creating the primary record is enough. For posting routines and reports it usually is not: an incomplete `[GIVEN]` produces a test that either fails with a setup error unrelated to the scenario, or worse, passes without ever reaching the logic it claims to verify.

## Best Practice

For a posting test, set up the full posting-group chain the document requires (e.g. customer/vendor posting group, gen. business/product posting group, VAT posting setup), the setup records the specific posting path reads, and an explicit date when the path is date-sensitive — a missing link surfaces as an unrelated G/L error, not a meaningful test failure. For a report test that claims to verify filtering or dataset logic, include both a record that should be included and one that should be excluded, plus any request-page parameter or FlowField the report's logic branches on. A report test that only claims to run without error is exempt from the include/exclude pairing, but it must say so in its scenario name or comment — an unlabelled single-record `[GIVEN]` is ambiguous about which claim it is making, and that ambiguity is itself the defect.

See sample: `given-blocks-must-cover-full-precondition-chain.good.al`.

## Anti Pattern

A posting test whose `[GIVEN]` creates only the sales header, relying on whatever posting groups happen to exist in the test company. A report test whose `[GIVEN]` creates only matching records, so the report "passes" whether or not its filter logic does anything at all.

See sample: `given-blocks-must-cover-full-precondition-chain.bad.al`.
