---
bc-version: [all]
domain: style
keywords: [parentheses, function-call, aa0008, invocation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Every function call carries parentheses, even with no arguments

## Description

AL allows `Customer.Init`, `TempBuffer.DeleteAll`, and `Customer.FindFirst` without trailing parentheses when the method takes no parameters. CodeCop rule AA0008 requires the parentheses anyway. The reason is readability: without `()`, the reader has to know the member is a method and not a property — an ambiguity that resolves differently for the platform's own APIs (FindFirst is a method; `Name` is a field). With `()`, the call site is visibly a method invocation and a simple grep for `Init(` or `DeleteAll(` finds every usage.

## Best Practice

Always write parentheses on method calls, even when empty: `Customer.Init()`, `TempBuffer.DeleteAll()`, `if Customer.FindFirst() then`. Apply the rule to platform methods and to user-defined procedures alike.

See sample: `require-parentheses-on-function-calls.good.al`.

## Anti Pattern

`Customer.Init;`, `TempBuffer.DeleteAll;`, `if Customer.FindFirst then` — all three compile but obscure what is a call and what is a field access. The inconsistency compounds when the same codebase has both conventions.

See sample: `require-parentheses-on-function-calls.bad.al`.
