---
bc-version: [all]
domain: performance
keywords: [short-circuit, lazy-evaluation, boolean-operators, nested-if, guard, and-operator, or-operator]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL boolean operators do not short-circuit

## Description

AL gives no short-circuit (lazy) evaluation guarantee for `and`, `or`, and `xor`: every operand of a boolean expression is evaluated, even when the leftmost operand already determines the result. Neither the AL operators documentation nor the boolean operators documentation defines a lazy evaluation order, so code must not depend on one. Developers arriving from C#, JavaScript, or SQL routinely assume the left operand guards the right; in AL it does not. The right operand still runs, so its cost is paid on every evaluation, and a check intended to protect an unsafe expression — an array subscript, a division, a field read that is only valid after a successful `Get` — does not protect it.

## Best Practice

Split a condition into nested `if` statements whenever one operand is only safe or only worth evaluating once another has passed. The guarding or cheapest condition goes in the outer `if`, the dependent or expensive one in the inner `if`, which makes the dependency explicit and keeps the expensive operand off the path that would have been skipped. Where there is no `else` branch, nesting is a pure win; where there is one, extract the conditions into a helper procedure that exits early instead. Where the chain runs past about three conditions, stop nesting and use a `case` statement instead — see `case-true-of-for-long-condition-chains.md`. Keep `and` and `or` for operands that are independently safe and cheap — in-memory field comparisons, enum tests, bound checks — where combining them reads better and costs nothing.

See sample: `boolean-operators-do-not-short-circuit.good.al`.

## Anti Pattern

A single condition that joins a guard with an operand depending on that guard, or with an expensive operand, using `and` or `or`. The consequence is either wasted work on every evaluation — a database call or validation procedure invoked even when the outcome is already decided — or a runtime error or silently wrong result that the guard was written to prevent. Detection signals: an operand that indexes an array or list with a variable whose bounds are checked in a sibling operand; `Record.Get(...)` or a `Find`/`IsEmpty` call as one operand of `and` with a field read of the same record as another; a boolean-returning procedure call combined with a cheap field test. The pattern is common in code ported from a language that does short-circuit, and in conditions grown by appending a clause to an existing `if`.

See sample: `boolean-operators-do-not-short-circuit.bad.al`.

## See also

`case-true-of-for-long-condition-chains.md` covers what to do when nesting the conditions would go more than about three levels deep. `microsoft/knowledge/performance/apply-guards-before-get.md` covers the related ordering rule for statements rather than operands.
