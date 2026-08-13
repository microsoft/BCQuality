---
bc-version: [all]
domain: testing
keywords: [given, test-setup, posting, report, request-page, precondition, dataset, completeness]
technologies: [al]
countries: [w1]
application-area: [all]
---

# GIVEN blocks must cover the full precondition chain, not just the primary record

## Description

A `[GIVEN]` block ([[test-feature-scenario-tags]]) is only correct if it sets
up every precondition the code under test actually reads — not just the one
record the scenario is "about." For most master-data tests, creating the
primary record is enough. For **posting routines** and **reports**, it
usually is not, and an incomplete `[GIVEN]` produces a test that passes for
the wrong reason (it never truly exercises the logic being claimed) or
fails with an unrelated setup error that has nothing to do with the
scenario.

Observed repeatedly across CURABIS AL projects (2026-08): AI-written test
cases for posting and report scenarios create the primary document or
record but skip the setup records the posting/report logic silently
depends on, producing tests that either don't compile against a clean
company, or that "pass" without ever reaching the assertion the scenario
claims to prove.

## Posting Scenarios

A `[GIVEN]` block feeding a posting routine must account for:
- The posting-relevant setup records the routine reads (e.g. `Sales &
  Receivables Setup`, `General Ledger Setup`, `Inventory Setup`) —
  whichever ones the specific posting path touches.
- Number series, or an explicitly assigned document number if number
  series aren't part of the scenario.
- The full posting-group chain the document requires (e.g. Customer
  Posting Group + Gen. Business/Product Posting Group + VAT Posting
  Setup combination) — a missing link here fails with a G/L-account error
  that has nothing to do with what the test claims to verify.
- Dimension defaults, if the scenario's data flow requires them (see
  [[dimension-support-must-follow-dimensionmanagement-wiring-pattern]]).
- An explicit date (not an implicit reliance on the sandbox's current
  system date) when the posting path is date-sensitive.

## Report Scenarios

A `[GIVEN]` block feeding a report test must include **both** a record
that should be included by the report's filters/dataset, **and** a record
that should be excluded — otherwise the test cannot distinguish "the
filter works" from "the filter does nothing." Also account for:
- Request page parameters the report's `OnPreDataItem`/`OnAfterGetRecord`
  logic branches on — a `[GIVEN]` that never sets a parameter the report
  reads is testing the report's default behavior only, not the scenario.
- Any FlowField/calculated data the report's dataset relies on, since
  those are easy to leave at zero/blank and get a report that "runs" but
  never touches the logic under test.

## Review Checklist

1. For a posting test: does `[GIVEN]` set up every posting group / setup
   record the routine will read, or only the primary document?
2. For a report test: does `[GIVEN]` include at least one record that
   should be filtered *out*, not only records that should appear?
3. Does `[GIVEN]` set dates/parameters explicitly wherever the code under
   test branches on them, rather than relying on sandbox defaults?
4. If posting or report execution fails with a setup-related error
   unrelated to the scenario's own claim, that is a `[GIVEN]` gap — fix
   the precondition, don't work around the error in `[WHEN]`/`[THEN]`.

## Source

Consultant feedback relayed by Michael Dieringer, 2026-08-13: AI-written
test cases for posting and report scenarios repeatedly under-specify
`[GIVEN]` conditions, requiring manual correction ("bare spørge den om at
huske at tænke over GIVEN condition"). Sharpens [[test-feature-scenario-tags]]
and [[test-setup-must-use-library-codeunit]], which cover comment structure
and setup centralization but not precondition completeness for these two
scenario types.
