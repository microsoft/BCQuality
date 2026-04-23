---
bc-version: [all]
domain: style
keywords: [this, codeunit, self-reference, aa0248, readability]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use the `this` keyword for codeunit self-reference

## Description

CodeCop rule AA0248 recommends the `this` keyword inside codeunit procedures when referring to the codeunit's own members or passing the codeunit itself to another procedure. AL's scope resolution otherwise blurs global-variable access, local-variable access, and same-codeunit method calls into the same unqualified syntax — a reader of `ValidateCustomer(Customer)` cannot tell at the call site whether `ValidateCustomer` is a local, a global, or a method on a different codeunit in scope. `this.ValidateCustomer(Customer)` removes the ambiguity, and `OtherCodeunit.DoWork(this)` is the only way to pass the current codeunit as a parameter.

## Best Practice

In codeunits, prefix same-codeunit method calls with `this.` when the call is ambiguous or when the scope spans more than a few lines. When the current codeunit needs to be passed as an argument, write `this` — there is no alternative syntax. The rule applies to codeunits; pages, reports, and tables have their own scoping.

See sample: `use-this-keyword-in-codeunits.good.al`.

## Anti Pattern

`ValidateCustomer(Customer); SomeOtherCodeunit.DoWork(/* this codeunit? */);` — the first call has ambiguous origin, and the second cannot pass the current codeunit without `this`. The style becomes load-bearing as the codeunit grows past a few small procedures.

See sample: `use-this-keyword-in-codeunits.bad.al`.
