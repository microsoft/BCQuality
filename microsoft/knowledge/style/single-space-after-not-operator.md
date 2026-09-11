---
bc-version: [all]
domain: style
keywords: [spacing, not, operator, aa0003, codecop]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Exactly one space between `not` and its argument (CodeCop AA0003)

## Description

CodeCop AA0003 requires exactly one space between the `not` operator and the expression it negates. `if not Customer.FindFirst() then …` is correct; `if not  Customer.FindFirst() then …` (two spaces) and `if notCustomer.FindFirst() then …` (zero — which fails parsing anyway) are not. The rule is also the place where uppercase `NOT` is flagged in combination with CodeCop AA0241 (reserved keywords must be lowercase): `if NOT Condition then` is doubly wrong.

## Best Practice

`if not Condition then`, `if not Customer.IsEmpty() then`, `exit(not Result)`. One space, lowercase keyword, no parentheses around the bare boolean.

See sample: [`single-space-after-not-operator.good.al`](single-space-after-not-operator.good.al).

## Anti Pattern

`if NOT condition then`, `if not  condition then`, `if !condition then` (which is not even AL — `!` is not a negation operator in AL). All three either trip AA0003 / AA0241 or fail to compile.

See sample: [`single-space-after-not-operator.bad.al`](single-space-after-not-operator.bad.al).
