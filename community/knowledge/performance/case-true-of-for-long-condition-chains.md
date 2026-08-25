---
bc-version: [all]
domain: performance
keywords: [case-statement, case-true-of, nested-if, condition-chain, guard, lazy-evaluation, nesting-depth]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use case true of for long chains of dependent conditions

## Description

Because AL gives no short-circuit guarantee for `and` and `or`, a chain of conditions that must be evaluated in order has to be sequenced with nested `if` statements — and past three conditions the nesting itself becomes the problem: the body drifts right, the order of evaluation is carried by indentation alone, and any shared failure path is repeated at every level. AL's `case` statement is the flat alternative. Its value sets "must be an expression or a range", so `case true of` and `case false of` accept arbitrary boolean expressions, and the statement "is evaluated, and the first matching value set executes the associated statement" — evaluation stops at the first match, which is exactly the laziness the boolean operators do not provide.

## Best Practice

Sequence two or three dependent conditions with nested `if`. Beyond that, switch to `case`: use `case false of` for a chain of guards where every condition must hold, listing the failure action per condition and letting control fall past `end` when all pass; use `case true of` for first-match dispatch, where each later probe runs only if the earlier ones did not match. Value sets that share an action may be comma-separated into one value set, but only when each is a pure, order-independent test — a field comparison or an enum check. A condition with a side effect, or one that is only safe after an earlier condition passed, keeps its own value set even when its action repeats, because ordered matching is guaranteed *across* value sets, not within one. This keeps every condition at one indentation level, makes evaluation order explicit rather than implied by nesting, and preserves the stop-at-first-match behaviour. It also aligns with the AL programming convention that more than two alternatives belong in a `case` statement rather than an `if-then-else`.

See sample: `case-true-of-for-long-condition-chains.good.al`.

## Anti Pattern

An `if` ladder four or more levels deep whose only purpose is sequencing guards. Detection: a chain of nested `if` statements with no `else`, each condition guarding the one below it, terminating in a single action or `exit`; or the same `exit`/`error` duplicated at every level of such a nested chain, purely to escape it. The second, worse form is collapsing that ladder into one `and` chain to escape the nesting — that trades indentation for a real defect, because the operands are still all evaluated. Reach for `case` instead of either.

See sample: `case-true-of-for-long-condition-chains.bad.al`.

## See also

`boolean-operators-do-not-short-circuit.md` covers the underlying evaluation rule that makes the sequencing necessary in the first place.
