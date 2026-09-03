---
bc-version: [all]
domain: appsource
keywords: [date-literal, invariant-date, dateformula, localization, appsourcecop]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use invariant date literals

## Description

Write fixed dates in AL with the invariant `yyyymmddD` syntax. A locale-dependent text value parsed with `Evaluate` can change meaning or fail under another user's regional settings, which makes the extension unreliable across AppSource markets.

## Best Practice

Represent a fixed date directly as an AL date literal, such as `20250131D`. Use `CalcDate` with a date formula when the value is relative rather than fixed.

See sample: `use-invariant-date-literals.good.al`.

## Anti Pattern

Building a fixed date by passing localized text such as `01/02/2025` to `Evaluate`. Detection signal: `Evaluate` converting a hard-coded or label-backed formatted string into a `Date`.

See sample: `use-invariant-date-literals.bad.al`.