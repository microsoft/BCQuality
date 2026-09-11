---
bc-version: [all]
domain: style
keywords: [block-keyword, end, if, repeat, until, for, while, case, aa0018]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Block keywords (`end`, `if`, `repeat`, `until`, `for`, `while`, `case`) start a new line (CodeCop AA0018)

## Description

CodeCop AA0018 requires that the block-introducing keywords `if`, `repeat`, `until`, `for`, `while`, `case`, and the block-terminating keyword `end` always start a new line. Multiple statements packed onto one line — `if A then X() else if B then Y();` written inline, or `for i := 1 to 10 do begin X(i); Y(i); end;` — defeat code review tooling that operates line-by-line and obscure the control flow. The rule does not prohibit short single-statement constructs spread across two lines (`if Cond then X();`); it prohibits packing the entire control structure onto one line.

## Best Practice

Each `if`, `else if`, `repeat`, `for`, `while`, and `case` starts a line. Each `end;` (the closing of a `begin … end` block or a `case`) starts a line. Branch bodies are on their own line, indented.

See sample: [`block-keywords-start-new-line.good.al`](block-keywords-start-new-line.good.al).

## Anti Pattern

`if IsContactName then ValidateContactName() else if IsSalespersonCode then ValidateSalespersonCode();` collapses an `if/else if` chain onto a single line; AA0018 flags both the `else` and the second `if`. The same applies to `for i := 1 to 10 do begin DoX(i); DoY(i); end;` — `end` is not at the start of its line.

See sample: [`block-keywords-start-new-line.bad.al`](block-keywords-start-new-line.bad.al).
