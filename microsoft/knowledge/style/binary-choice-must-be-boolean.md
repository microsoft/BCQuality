---
bc-version: [all]
domain: style
keywords: [boolean, option, yes-no, magic-number, variable-typing, field-typing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Binary yes/no choices must be typed as Boolean, not Option or Integer

> Contributions welcome — open a PR to refine or extend this article.

## Description

When a field or variable represents exactly two states — yes/no, on/off, active/inactive, blocked/not blocked — it should be typed `Boolean`. Modeling that same two-state choice as an `Option`/`Enum` with two members, or as an `Integer` with two magic-number values, adds a layer of indirection a reader has to resolve before understanding the code, and it invites a multi-branch check where a simple `if X then` would do. This is distinct from a genuine multi-value choice with more than two named states, which legitimately calls for `Enum` — the line is the state count.

## Best Practice

Type a true two-state field or variable as `Boolean` and branch on it directly.

See sample: `binary-choice-must-be-boolean.good.al`.

## Anti Pattern

Modeling a yes/no choice as an `Option` with two members, or as an `Integer` with magic-number values, forces every caller to remember which value means what and leaves room for a meaningless third value.

See sample: `binary-choice-must-be-boolean.bad.al`.
