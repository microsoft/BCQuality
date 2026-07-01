---
bc-version: [all]
domain: performance
keywords: [setloadfields, partial-records, just-in-time-load, field-reload, round-trip, lazy-load]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Touching an unlisted field after SetLoadFields forces a full-row reload

> Contributions welcome — open a PR to refine or extend this article.

## Description

`SetLoadFields` loads only the named fields, but the trap is what happens when code later reads a field that was *not* listed: the platform silently issues a second database round-trip and reloads the **entire row** for that record — per record. In a loop, a single overlooked field turns one cheap partial read into N full-row reloads, which is slower than never calling `SetLoadFields` at all. The optimization is only a win if the listed set covers every field touched anywhere downstream, not just in the immediate code block.

## Best Practice

Before adding `SetLoadFields`, audit the *whole* access lifecycle of the record variable — every field read in the loop body, in called procedures, in `OnValidate`/`OnAfterGetRecord`, and in anything that receives the record by reference — and list all of them. If you cannot enumerate them confidently (for example the record is passed to code you do not control), prefer not to call `SetLoadFields` rather than risk the reload penalty. See the existing guidance on when partial records pay off (`use-setloadfields-for-partial-records`).

## Anti Pattern

Adding `SetLoadFields(Field1, Field2)` at the top of a loop, then reading `Field3` deeper in the body or in a helper. The code compiles and returns correct data, but each iteration pays a hidden full-row reload — the change reads as an optimization while regressing performance. Reviewer signal: a `SetLoadFields` list that does not include every field subsequently referenced through that record variable.
