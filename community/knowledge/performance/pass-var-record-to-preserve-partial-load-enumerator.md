---
bc-version: [all]
domain: performance
keywords: [setloadfields, jit-load, enumerator, var-parameter, pass-by-value, next]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pass the iterated record var so a JIT load updates the enumerator

> Contributions welcome — open a PR to refine or extend this article.

## Description

A `FindSet`/`Next` loop builds an enumerator from the fields selected for load. Accessing an unloaded field triggers a JIT load. When the record is passed **by value**, the copy does not share that enumerator: the JIT loads the copy and leaves the enumerator unchanged, so **every later `Next()` JIT-loads again**. Passing `var` lets the first JIT update the enumerator. `AddLoadFields` on the original record before a by-value call is the other fix. This is independent of whether `SetLoadFields` was ordered before filters.

## Best Practice

Helpers that read extra fields on an in-flight iterator must take the record as `var`, or the caller must `AddLoadFields` those fields before the loop. Prefer declaring the extra fields up front so no JIT is needed.

See sample: `pass-var-record-to-preserve-partial-load-enumerator.good.al`.

## Anti Pattern

A `SetLoadFields` loop that passes the iterator by value into a helper which then reads a field that was not loaded. The first row pays one JIT; every subsequent row pays it again because the enumerator never learned the extra field.

See sample: `pass-var-record-to-preserve-partial-load-enumerator.bad.al`.
