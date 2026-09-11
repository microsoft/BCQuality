---
bc-version: [all]
domain: style
keywords: [begin, end, compound-statement, aa0005, codecop, formatting]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `begin` goes on the same line as `then`, `else`, or `do` (CodeCop AA0005)

## Description

When a compound block follows `then`, `else`, or `do`, the `begin` keyword must sit on the same line as the preceding keyword, separated by exactly one space. `if Condition then begin` and `for i := 1 to N do begin` are correct. The form that puts `begin` on its own line — common in older AL and in languages like Pascal — is flagged by CodeCop AA0005. The rule does not change indentation of the block body; it only governs the placement of `begin` relative to `then`/`else`/`do`.

## Best Practice

`if Condition then begin … end;`, `else begin … end;`, `for i := 1 to N do begin … end;`. The block body is indented one level below the `if`/`for` line, and `end;` sits at the same indentation as the line that opened the block.

See sample: [`begin-on-same-line-as-then-else-do.good.al`](begin-on-same-line-as-then-else-do.good.al).

## Anti Pattern

A line that ends with `then` (or `else`, or `do`) and is followed by a line whose only content is `begin`. The compiler accepts it but CodeCop AA0005 flags it; the visual cost is a wasted line per block and a layout that looks alien to readers used to current AL style.

See sample: [`begin-on-same-line-as-then-else-do.bad.al`](begin-on-same-line-as-then-else-do.bad.al).
