---
bc-version: [all]
domain: style
keywords: [variable-declaration, order, var, complex-types, aa0021]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Order variable declarations by type, complex types first (CodeCop AA0021)

## Description

CodeCop AA0021 requires that variable declarations inside a `var` block follow a fixed ordering by type, with complex (composite) types appearing before primitive types. The canonical order is `Record`, then `Report`, `Codeunit`, `XmlPort`, `Page`, `Query`, `Notification`, `BigText`, `DateFormula`, `RecordId`, `RecordRef`, `FieldRef`, `FilterPageBuilder`, then the simple types `Text`, `Code`, `Integer`, `Decimal`, `Boolean`, `Date`, `Time`, `DateTime`, `Char`, `Byte`. Inside each type group the variables can be alphabetical or in usage order. Temporary records still sort under `Record`.

## Best Practice

Declare all `Record` variables first, then other complex types, then primitives. A consistent order makes diffs review-friendly and matches the convention enforced by the AL formatter and CodeCop.

See sample: [`variable-declaration-order-by-type.good.al`](variable-declaration-order-by-type.good.al).

## Anti Pattern

A `var` block where records and primitives are interleaved — `CustomerNo: Code[20];` between two `Record` variables, or `Amount: Decimal;` declared above the `Customer: Record Customer;` it is computed from. AA0021 flags it and the block is harder to scan; readers expect composite types at the top.

See sample: [`variable-declaration-order-by-type.bad.al`](variable-declaration-order-by-type.bad.al).
