---
bc-version: [all]
domain: style
keywords: [else, exit, break, skip, quit, error, terminating, control-flow]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Omit `else` when the `then` branch ends with `exit`, `break`, `skip`, `quit`, or `error`

## Description

When the `then` branch of an `if` ends in a terminating statement — `exit`, `break`, `skip`, `quit`, or `error` — the `else` branch becomes the natural fall-through. `if Cond then exit; DoX();` and `if Cond then exit else DoX();` are equivalent, and the second form adds a layer of nesting that the reader has to mentally flatten. The same applies to `Error(...)`: `if IsAdjmtBinCodeChanged() then Error(AdjmtErr) else Error(BinErr);` is better written as `if IsAdjmtBinCodeChanged() then Error(AdjmtErr); Error(BinErr);` — the second `Error` is always reached when the first branch is not taken.

## Best Practice

Drop the `else` when the `then` branch unconditionally exits the procedure or the enclosing loop. The body that would have been inside `else` becomes the unindented continuation.

See sample: [`no-else-after-terminating-statement.good.al`](no-else-after-terminating-statement.good.al).

## Anti Pattern

An `if … then Error(…) else Error(…)` pair where both branches terminate. The `else` is structural noise — the reader cannot tell at a glance whether it exists to handle an actual continuation or simply mirrors the `then`. The fix is to drop `else` and let the second `Error` fall through naturally.

See sample: [`no-else-after-terminating-statement.bad.al`](no-else-after-terminating-statement.bad.al).
