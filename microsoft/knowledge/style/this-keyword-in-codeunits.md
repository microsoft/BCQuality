---
bc-version: [25..]
domain: style
keywords: [this, codeunit, self-reference, aa0248, scope]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use the `this` keyword for self-reference inside codeunits (CodeCop AA0248)

## Description

CodeCop AA0248 recommends prefixing self-references inside a codeunit with `this`. `this.ValidateCustomer(Customer)` is unambiguous: the call resolves to a procedure on the current codeunit, not to a local variable or a procedure on a passed-in object. Without the prefix, a reader of a 200-line procedure has to scan the whole codeunit to confirm whether `ValidateCustomer` is local. `this` also makes it possible to pass the current codeunit as an argument — `SomeOtherCodeunit.DoWork(this)` — which is the only way to expose the running codeunit instance to a collaborator. The rule applies only to codeunits, not to pages, reports, queries, or tables — those object types do not have a `this` reference in AL.

## Best Practice

Inside a codeunit, prefix calls to procedures and accesses to global variables on the same codeunit with `this.`, and pass `this` when an external codeunit needs a reference to the running instance.

See sample: `this-keyword-in-codeunits.good.al`.

## Anti Pattern

Calling a codeunit-local procedure as a bare identifier (`ValidateCustomer(Customer)`) when other readings are possible. The ambiguity costs reading time on every encounter and grows with codeunit size.

See sample: `this-keyword-in-codeunits.bad.al`.
