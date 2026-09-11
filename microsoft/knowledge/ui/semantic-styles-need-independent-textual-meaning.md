---
bc-version: [all]
domain: ui
keywords: [style, favorable, unfavorable, ambiguous, color, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Semantic styles need independent textual meaning

## Description

Three `Style` values carry semantic meaning through color and must be backed by text that conveys the same meaning:

- `Favorable` (Bold + Green) — implies a positive outcome.
- `Unfavorable` (Bold + Italic + Red) — implies a negative outcome.
- `Ambiguous` (Yellow) — implies an uncertain or mixed outcome.

For accessibility, assume the style is completely invisible to the user. The semantic meaning must be independently determinable from at least one of:

1. The **field caption** matches the semantic meaning (e.g. caption "Error" with `Style = Unfavorable`, or "Profit" with `Style = Favorable`).
2. The **field value** communicates the meaning (e.g. value "Success!" with Favorable, a negative number with Unfavorable).
3. An **adjacent field** provides a textual representation of the semantic meaning (e.g. a "Status" column reads "High" / "Medium" / "Low" alongside a percentage field).

The rule applies equally whether `Style` is set to a literal value or to a variable that evaluates to a semantic style at runtime.

## Best Practice

When you reach for `Favorable`, `Unfavorable`, or `Ambiguous`, verify that the caption, value, or an adjacent column already conveys the same meaning. See sample: [`semantic-styles-need-independent-textual-meaning.good.al`](semantic-styles-need-independent-textual-meaning.good.al).

## Anti Pattern

Applying a semantic style for purely cosmetic emphasis (e.g. green company name for aesthetics), or using semantic colors where only the color reveals the threshold (e.g. confidence percentages with no qualitative label). See sample: [`semantic-styles-need-independent-textual-meaning.bad.al`](semantic-styles-need-independent-textual-meaning.bad.al).
