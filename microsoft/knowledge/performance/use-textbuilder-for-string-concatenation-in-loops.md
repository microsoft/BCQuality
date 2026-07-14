---
bc-version: [all]
domain: performance
keywords: [textbuilder, string-concatenation, loop, append, immutable-text]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use AL TextBuilder for repeated text mutation

## Description

AL `TextBuilder` is a reference type intended for modifying text without creating a new `Text` value for each change. Microsoft documents it as the performance-oriented AL primitive for concatenating many strings, including loop-built output. `Append` and `AppendLine` build the value, and `ToText` returns the completed text.

## Best Practice

When a loop repeatedly appends fragments to one result, use a `TextBuilder` local and convert once after the loop. Keep ordinary `Text` expressions for a fixed, small number of fragments; this rule is about repeated mutation, not every concatenation.

## Anti Pattern

Building an unbounded export or message with `Result += Fragment` on every iteration when AL's `TextBuilder` directly represents the operation.
