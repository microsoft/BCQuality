---
bc-version: [all]
domain: style
keywords: [spacing, parenthesis, method-call, aa0002, codecop]
technologies: [al]
countries: [w1]
application-area: [all]
---

# No space between a method name and its opening parenthesis (CodeCop AA0002)

## Description

CodeCop AA0002 forbids whitespace between a procedure/method name and its `(`. `Customer.Get(CustomerNo)` is correct; `Customer.Get (CustomerNo)` is not. The rule applies to user-defined procedures, system methods (`Insert`, `FindFirst`, `CalcFields`), trigger-style invocations, and the parenthesised cast/conversion forms (`Format(Value)`, `CopyStr(Source, 1, 10)`). The whitespace between `(` and the first argument, and between the last argument and `)`, is also forbidden by the same rule.

## Best Practice

`Customer.Get(CustomerNo)`, `Customer.SetFilter("No.", '%1', '*A*')`, `Message(GreetingMsg, UserName)`. The standard AL formatter enforces this automatically.

See sample: [`no-space-before-method-parenthesis.good.al`](no-space-before-method-parenthesis.good.al).

## Anti Pattern

`Customer.Get ( CustomerNo )`, `Message ( GreetingMsg, UserName )`. Both trip AA0002 and read as if the call had an extra unnamed parameter — a small but persistent friction every reader pays.

See sample: [`no-space-before-method-parenthesis.bad.al`](no-space-before-method-parenthesis.bad.al).
