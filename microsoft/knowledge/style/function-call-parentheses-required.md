---
bc-version: [all]
domain: style
keywords: [parentheses, function-call, method-call, aa0008, codecop]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Always write parentheses on procedure calls (CodeCop AA0008)

## Description

AL allows a parameterless procedure to be called without parentheses — `Customer.Init` instead of `Customer.Init()` — and the result is syntactically identical at runtime. CodeCop AA0008 still flags the parenthesis-less form. The reason is twofold: written without parentheses, a procedure call is visually indistinguishable from a property read, which makes BC code harder to scan; and the same identifier may exist as both a property and a procedure on different objects, so the parentheses are the only local signal that this is a call. The rule applies to every parameterless invocation, including `Init`, `Insert`, `Modify`, `Delete`, `DeleteAll`, `FindFirst`, `FindSet`, `Next`, `Get`, `CalcFields`, and user-defined procedures.

## Best Practice

Always write `()` on a procedure call, even when it takes no arguments: `Customer.Init();`, `TempBuffer.DeleteAll();`, `if Customer.FindFirst() then …`. The same applies inside expressions and as a condition.

See sample: [`function-call-parentheses-required.good.al`](function-call-parentheses-required.good.al).

## Anti Pattern

`Customer.Init;`, `TempBuffer.DeleteAll;`, `if Customer.FindFirst then …`. Every one of those is an AA0008 violation. Reviewers should treat a parameterless procedure name appearing without parentheses as a defect, even though the compiler accepts it.

See sample: [`function-call-parentheses-required.bad.al`](function-call-parentheses-required.bad.al).
