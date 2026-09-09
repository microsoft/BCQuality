---
bc-version: [all]
domain: style
keywords: [begin, end, single-statement, aa0013, codecop, compound]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not wrap a single statement in `begin … end` (CodeCop AA0013)

## Description

CodeCop AA0013 flags `begin … end` blocks that contain exactly one statement. The compound-block syntax exists to group multiple statements as a unit; using it for a single statement adds two lines and a level of nesting without adding meaning. `if IsAssemblyOutputLine then begin TestField("Order Line No.", 0); end;` should be `if IsAssemblyOutputLine then TestField("Order Line No.", 0);` — one statement, no block. The same logic applies after `else`, `for`, `while`, and `repeat`.

## Best Practice

A single statement following `then`, `else`, `do`, or a case label is written on its own line, indented one level, with no `begin … end`. Use `begin … end` only when there are two or more statements to group.

See sample: [`no-begin-end-around-single-statement.good.al`](no-begin-end-around-single-statement.good.al).

## Anti Pattern

`if Cond then begin OneCall(); end;` — single statement wrapped in a block. AA0013 flags it. The reviewer signal is "a `begin` followed by exactly one statement before its `end`."

See sample: [`no-begin-end-around-single-statement.bad.al`](no-begin-end-around-single-statement.bad.al).
