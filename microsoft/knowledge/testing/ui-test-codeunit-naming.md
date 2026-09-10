---
bc-version: [all]
domain: testing
keywords: [ui-test, testpage, naming, suffix, codeunit, page-testing, team-convention]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Separate UI-layer and logic-layer tests into different codeunits

## Description

A test codeunit that drives pages through `TestPage` — opening pages, reading FactBox parts, triggering field `OnValidate` through the page — is testing a different layer than a codeunit that calls business-logic procedures directly. Readers need to know which layer a given test exercises without opening it, and a single codeunit that mixes both kinds of test hides that distinction: a failure could mean the logic broke, the page broke, or both. The `_UT` suffix and adjacent-object-ID pairing below are one team's naming convention for making that split visible, not a BCApps-wide naming standard — BCApps itself uses `UT` for unit tests generally, not specifically to mean "UI layer," and does not treat adjacent object IDs as a semantic pairing mechanism. Apply the suffix only on a project that has explicitly adopted this convention.

## Best Practice

Keep UI-layer (`TestPage`-driven) and logic-layer tests in separate codeunits regardless of naming. Projects that adopt a `_UT`-style suffix convention should apply it consistently to every UI-layer test codeunit, keep the corresponding logic-only codeunit unsuffixed, and document the convention where the team's other naming rules live.

See sample: `ui-test-codeunit-naming.good.al`.

## Anti Pattern

One codeunit that mixes a direct logic-call test and a `TestPage`-driven test side by side — a failing test no longer tells a reader which layer actually broke. On a project that has adopted the `_UT` convention, a UI-layer codeunit missing the suffix is also an instance of this anti-pattern; on a project that has not adopted it, the suffix itself is not required.

See sample: `ui-test-codeunit-naming.bad.al`.
