---
bc-version: [all]
domain: data-modeling
keywords: [tablerelation, tableextension, enumextension, additive, top-down, unconditional-relation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Design TableRelation branches for additive top-down extension

## Description

A `tableextension` can add to an existing `TableRelation`, but the combined relation is evaluated top-down after the original value. The first unconditional relation wins. An extension branch appended after an unconditional base relation is therefore unreachable, even though the extension compiles and appears to describe the new enum value correctly.

## Best Practice

When a relation is designed to follow an extensible enum, express the base cases as conditional branches and leave no unconditional catch-all ahead of future extension branches. An enum extension can then append a condition for its new value. When extending a field you do not own, inspect the original `TableRelation`; do not claim that an appended condition overrides an unconditional relation.

See sample: `table-relation-extensions-are-additive-and-top-down.good.al`.

## Anti Pattern

A base field has an unconditional `TableRelation = Customer;` and a `tableextension` adds `if (Type = const(Resource)) Resource`. The original unconditional branch always wins, so the new enum value still validates and looks up against Customer. The concern is evaluation order, not `ValidateTableRelation`; free-form input is covered separately by security guidance.

See sample: `table-relation-extensions-are-additive-and-top-down.bad.al`.
