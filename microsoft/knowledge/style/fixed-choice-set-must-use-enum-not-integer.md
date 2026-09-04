---
bc-version: [all]
domain: style
keywords: [enum, option, integer, magic-number, variable-typing, field-typing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A fixed set of named choices must use Enum, not a raw Integer

> Contributions welcome — open a PR to refine or extend this article.

## Description

When a variable or field can only take on a fixed set of more than two named, mutually exclusive states — a difficulty level, a document type, a processing status — it should be typed as `Enum` (or `Option` when extending an object that still uses the legacy type). Representing that same state as a plain `Integer` and tracking the meaning of each value in a comment or in a developer's head is a magic-number anti-pattern: the compiler cannot catch an out-of-range value, and branches read as opaque numbers instead of names. This is distinct from a true two-state choice, which should be `Boolean` rather than an enumeration — the line is the state count.

## Best Practice

Declare an `Enum` with named values and branch on the enum value, not a raw number.

See sample: `fixed-choice-set-must-use-enum-not-integer.good.al`.

## Anti Pattern

Using a plain `Integer` field with the meaning of each value tracked only in a comment pushes the documentation of the states into something the compiler cannot check and a future maintainer cannot rely on.

See sample: `fixed-choice-set-must-use-enum-not-integer.bad.al`.
