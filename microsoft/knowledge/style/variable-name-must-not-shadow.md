---
bc-version: [all]
domain: style
keywords: [variable-name, shadow, conflict, aa0198, aa0202, aa0204, codecop]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Local variable names must not shadow globals, fields, methods, or actions (CodeCop AA0198/AA0202/AA0204)

## Description

Three CodeCop rules — AA0198, AA0202, AA0204 — together forbid a local variable from sharing a name with a global variable on the same object, with a field on the same table or page source, with a procedure on the same object, or with an action on the same page. The compiler resolves the conflict by binding the closer scope, so a local `Customer: Text` will silently override a global `Customer: Record Customer` for the duration of a procedure — every call site reading `Customer.Name` from inside that procedure refers to the text, and the breakage is invisible to a reader who has both declarations on screen.

## Best Practice

Differentiate every local declaration from globals, fields, procedures, and actions on the same object. `Customer` global plus `CustomerName` local; method `GetAmount` plus local `SalesAmount`. The standard pattern is to attach a noun suffix to the local (`CustomerName`, `CustomerRec`, `CustomerNo`) rather than to the global.

See sample: [`variable-name-must-not-shadow.good.al`](variable-name-must-not-shadow.good.al).

## Anti Pattern

A procedure that declares a local `Customer: Text` inside a codeunit that already has a global `Customer: Record Customer`. The local wins and the global becomes unreachable inside the procedure. AA0198/AA0202/AA0204 flag this category of conflict whether the colliding entity is a global, a field, a method, or an action.

See sample: [`variable-name-must-not-shadow.bad.al`](variable-name-must-not-shadow.bad.al).
