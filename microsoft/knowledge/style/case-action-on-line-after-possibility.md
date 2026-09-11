---
bc-version: [all]
domain: style
keywords: [case, statement, formatting, possibility, action, line-break]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `case` action goes on the line after the possibility

## Description

In an AL `case` statement, the action for each label is written on the line that follows the label, not on the same line. `'A': Letter2 := '10';` on a single line is the discouraged form; the convention is `'A':` on one line and `Letter2 := '10';` on the next, indented one level deeper. The exception is when the action is a `begin … end` block — there the `begin` follows the colon on the same line, consistent with the rule for `then begin` / `else begin` / `do begin`.

## Best Practice

Each case label sits on its own line, terminated by `:`. The action below it is indented; multi-statement actions open with `begin` on the label line and close with `end;` on its own line.

See sample: [`case-action-on-line-after-possibility.good.al`](case-action-on-line-after-possibility.good.al).

## Anti Pattern

`'A': Letter2 := '10';` (single-line label and action), and `'C': begin Letter2 := '12'; DoSomething(); end;` (everything on one line including the block body). Both defeat per-line diff review and crowd the control flow.

See sample: [`case-action-on-line-after-possibility.bad.al`](case-action-on-line-after-possibility.bad.al).
