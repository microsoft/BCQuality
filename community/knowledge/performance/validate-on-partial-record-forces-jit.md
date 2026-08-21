---
bc-version: [all]
domain: performance
keywords: [validate, setloadfields, jit-load, table-relation, onvalidate, partial-record]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Validate on a partial record forces JIT loads

> Contributions welcome — open a PR to refine or extend this article.

## Description

`Validate` runs the field's `OnValidate` trigger and TableRelation lookups. Those code paths routinely touch other fields on the same record. On a partial row those extra fields are not loaded, so the platform JIT-loads them — often the rest of the row — plus any related-table reads the trigger performs. Distinct from `skip-setloadfields-on-write-and-transferfields.md`: the write may be `Modify(false)`; `Validate` is what blows the partial load. Agents that combine `SetLoadFields` with `Validate` in a loop produce slower code than an unoptimized assignment.

## Best Practice

In a partial-record loop, assign fields directly when trigger side effects are not required. If `Validate` is required, do not use `SetLoadFields` on that iterator, or `AddLoadFields` every field the validate path can touch before the read.

See sample: `validate-on-partial-record-forces-jit.good.al`.

## Anti Pattern

`SetLoadFields` on a handful of columns, then `Validate` inside the loop. The load list looks optimal; runtime JIT and TableRelation I/O dominate. The signal is `Validate(` on a record that still has a `SetLoadFields` in the same procedure.

See sample: `validate-on-partial-record-forces-jit.bad.al`.
