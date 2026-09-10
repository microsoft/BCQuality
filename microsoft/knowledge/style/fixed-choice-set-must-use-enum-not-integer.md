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

When a variable or field represents a fixed set of named, mutually exclusive states — a difficulty level, a document type, a processing status — it should be typed as `Enum` (or `Option` when extending an object that still uses the legacy type). Representing that same state as a plain `Integer` and tracking the meaning of each value in a comment or in a developer's head is a magic-number anti-pattern: the compiler cannot catch an out-of-range value, and branches read as opaque numbers instead of names. This is about semantics, not member count, matching `binary-choice-must-be-boolean.md`'s own distinction: a domain concept that is genuinely a stable true/false predicate belongs in `Boolean` even if someone represents it as a two-value `Enum`, while a domain concept with exactly two current named states is not automatically a Boolean in disguise — it stays an `Enum` when the states are named alternatives rather than a yes/no flag, or when it needs to implement an interface, preserve an existing contract, or leave room for a future third value.

## Best Practice

Declare an `Enum` with named values and branch on the enum value, not a raw number.

See sample: `fixed-choice-set-must-use-enum-not-integer.good.al`.

## Anti Pattern

Using a plain `Integer` field with the meaning of each value tracked only in a comment pushes the documentation of the states into something the compiler cannot check and a future maintainer cannot rely on.

See sample: `fixed-choice-set-must-use-enum-not-integer.bad.al`.
