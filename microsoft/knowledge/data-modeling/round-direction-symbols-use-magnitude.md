---
bc-version: [all]
domain: data-modeling
keywords: [round, rounding, direction, precision, negative-decimal, amount]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `Round` direction symbols follow magnitude, not mathematical ordering

## Description

AL's `Round(Number, Precision, Direction)` uses `'>'` to round away from zero and `'<'` to round toward zero. For a negative value this reverses mathematical ordering: `Round(-1234.56789, 0.001, '<')` returns `-1234.567`, while direction `'>'` returns `-1234.568`. Code that treats the symbols as mathematical ceiling and floor produces sign-dependent amount errors, commonly on credit documents and negative adjustments.

## Best Practice

Choose the direction from the business meaning: `'>'` increases absolute magnitude and `'<'` decreases absolute magnitude for both positive and negative values. Include positive and negative cases whenever a directed rounding rule is tested.

See sample: `round-direction-symbols-use-magnitude.good.al`.

## Anti Pattern

Using `'<'` as a mathematical floor or `'>'` as a mathematical ceiling. The result looks correct for positive amounts but moves in the opposite mathematical direction for negative amounts.

See sample: `round-direction-symbols-use-magnitude.bad.al`.

## Reference

[Use the Round function](https://learn.microsoft.com/en-us/training/modules/use-document-standards-business-central/4a-use-round-function)
