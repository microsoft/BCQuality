---
bc-version: [all]
domain: style
keywords: [spacing, binary-operator, aa0001, codecop, formatting]
technologies: [al]
countries: [w1]
application-area: [all]
---

# One space on each side of every binary operator (CodeCop AA0001)

## Description

CodeCop AA0001 requires exactly one space on each side of every binary operator: assignment (`:=`), arithmetic (`+`, `-`, `*`, `/`, `mod`, `div`), comparison (`=`, `<>`, `<`, `<=`, `>`, `>=`), logical (`and`, `or`, `xor`), and string concatenation. `x:=1+2`, `Price:=Amount*Quantity`, `if a=b then`, and `if a and b then` all violate the rule. The rule applies to the binary use of `-` (subtraction); the unary minus (`-Profit`) takes no leading space.

## Best Practice

Write `x := 1 + 2`, `Price := Amount * Quantity`, `if a = b then`, `if a and b then`. The standard AL formatter inserts these spaces automatically; running `Alt+Shift+F` (Format Document) in the AL extension is the simplest way to bring an entire file into compliance.

See sample: [`single-space-around-binary-operators.good.al`](single-space-around-binary-operators.good.al).

## Anti Pattern

`x:=1+2;`, `Price:=Amount*Quantity;`, `if a=b then`, `if a and b then`. All trip AA0001.

See sample: [`single-space-around-binary-operators.bad.al`](single-space-around-binary-operators.bad.al).
