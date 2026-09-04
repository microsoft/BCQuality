---
bc-version: [all]
domain: testing
keywords: [ui-test, testpage, naming, suffix, codeunit, page-testing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Suffix UI-layer test codeunits with _UT and never mix layers in one codeunit

## Description

A test codeunit that drives pages through `TestPage` — opening pages, reading FactBox parts, triggering field `OnValidate` through the page — is testing a different layer than a codeunit that calls business-logic procedures directly. Readers need to know which layer a given test exercises without opening it, and a single codeunit that mixes both kinds of test hides that distinction: a failure could mean the logic broke, the page broke, or both.

## Best Practice

Give any test codeunit that uses `TestPage` a `_UT` (Unit Test — UI layer) suffix, and keep it free of tests that call codeunit/table procedures directly. Keep the corresponding logic-only codeunit unsuffixed. Allocate the two codeunits adjacent object IDs so their relationship is visible in the object list.

See sample: `ui-test-codeunit-naming.good.al`.

## Anti Pattern

A codeunit named without the `_UT` suffix that nonetheless contains `TestPage` calls, or — worse — one codeunit that mixes a direct logic-call test and a `TestPage`-driven test side by side. Either way, the codeunit's name no longer tells a reader which layer a failing test actually broke.

See sample: `ui-test-codeunit-naming.bad.al`.
