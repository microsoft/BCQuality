---
bc-version: [all]
domain: style
keywords: [var-parameter, by-reference, pass-by-reference, literal, constant, compile-error, procedure-call]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A `var` parameter must be called with a variable, never a literal or expression

> Contributions welcome — open a PR to refine or extend this article.

## Description

When a procedure declares a parameter with `var`, that parameter is passed by reference: the callee writes back into the caller's own memory location. This means the argument at the call site must be an actual variable, something with an address. A string literal, a numeric constant, or a computed expression has no address to write back to, so passing one to a `var` parameter fails to compile. Before writing a call, check the callee's signature for `var` on each parameter position being supplied a literal or expression — if present, a variable declared in the caller's own scope must be used instead.

## Best Practice

Declare a variable in the caller's scope and pass it to the `var` parameter.

See sample: `var-parameters-require-an-addressable-variable.good.al`.

## Anti Pattern

Passing a literal or a computed expression to a `var` parameter position fails to compile, because neither has an address the callee can write back to.

See sample: `var-parameters-require-an-addressable-variable.bad.al`.
