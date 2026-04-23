---
bc-version: [all]
domain: performance
keywords: [setloadfields, heuristics, narrow-table, short-loop, diminishing-returns]
technologies: [al]
countries: [w1]
application-area: [all]
---

# SetLoadFields pays off at scale; skip it on narrow tables and short loops

## Description

`SetLoadFields` reduces the number of columns the platform hydrates per record. It delivers real savings on wide tables with blob, media, or many text fields when the iteration touches a small subset. Below certain thresholds the accounting flips the other way: narrow tables (fewer than ~10 fields) save almost nothing per row, and short loops (fewer than ~10 iterations) amortize the narrowing over too few fetches to outweigh the extra code and the specification-and-access-set coupling that future edits have to maintain. Recommending SetLoadFields on every Find/Get call produces low-value churn and invites the opposite mistake — listing a field in SetLoadFields and then forgetting to access it, which triggers a second round-trip to load the missing field.

## Best Practice

Reach for SetLoadFields when the table is wide (10+ fields, especially with blobs) AND the code path reads a small subset AND the iteration or fetch count is material. When in doubt on a short loop over a narrow table, leave SetLoadFields out; the complexity cost is not earned. The filter-only-field rule from `omit-filter-only-fields-from-setloadfields` still applies: fields used only in filters stay out of the list.

## Anti Pattern

A 5-row loop over a 6-field setup table prefaced by `Rec.SetLoadFields(...)`. The author has added two lines of code, coupled the loop to a field specification that needs to be updated on every schema change, and saved nanoseconds. The same pattern applied mechanically to every Find call in a codebase produces hundreds of diffs that do not move the performance needle.
