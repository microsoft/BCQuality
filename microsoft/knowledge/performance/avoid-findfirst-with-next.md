---
bc-version: [all]
domain: performance
keywords: [findfirst, findlast, get, next, aa0233]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not pair FindFirst, FindLast, or Get with Next

## Description

CodeCop rule AA0233 flags loops that start with FindFirst, FindLast, or Get and then call Next. FindFirst and FindLast retrieve a single row and reposition the cursor; calling Next after them forces the platform to re-seek and stream the rest of the set, which is slower than the correct FindSet pattern and signals intent incorrectly to reviewers and the optimizer.

## Best Practice

Choose the Find variant that matches the operation: FindSet for full iteration, FindFirst or FindLast when you want exactly one row, Get when the primary key is known. Never call Next after FindFirst, FindLast, or Get.

## Anti Pattern

Writing `if Rec.FindFirst() then repeat ... until Rec.Next() = 0` is the canonical AA0233 offender. The loop wastes bandwidth and obscures the author's intent.

See sample: `avoid-findfirst-with-next.bad.al`.

