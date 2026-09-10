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

When a field or variable represents a genuine true/false state — yes/no, on/off, active/inactive, blocked/not blocked — it should be typed `Boolean`. Modeling that same predicate as an `Option`/`Enum` with two members, or as an `Integer` with two magic-number values, adds a layer of indirection a reader has to resolve before understanding the code. This is about semantics, not member count: a domain concept that currently has exactly two named alternatives — Inbound/Outbound, Debit/Credit, Buy/Sell — is not automatically a Boolean in disguise. An `Enum` can be the clearer model there, including when it needs to implement an interface, preserve an existing contract, or leave room for a future third value. The distinction is whether the domain is genuinely a stable predicate, not how many states it currently has.

## Best Practice

Type a field or variable as `Boolean` when the domain concept is inherently a true/false state. Do not replace a meaningful two-option domain model with a Boolean solely because it currently has two values.

See sample: `binary-choice-must-be-boolean.good.al`.

## Anti Pattern

Modeling a yes/no choice as an `Option` with two members, or as an `Integer` with magic-number values, forces every caller to remember which value means what and leaves room for a meaningless third value.

See sample: `binary-choice-must-be-boolean.bad.al`.
