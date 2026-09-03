---
bc-version: [all]
domain: performance
keywords: [job-queue, category-code, concurrency, waiting, serialization, locking]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use a job queue category to serialize conflicting jobs

> Contributions welcome — open a PR to refine or extend this article.

## Description

Different job queue entries can run at the same time. When two jobs update the same exclusive resource, concurrent execution can cause lock contention, deadlocks, or conflicting results. Entries with the same Job Queue Category Code are serialized: while one runs, another entry in that category waits.

## Best Practice

Assign the same non-empty Job Queue Category Code to jobs that must not overlap, regardless of which codeunit they run. Define categories around the shared resource or exclusivity requirement, not merely around object names. Leave independent jobs in different categories so they can still run concurrently.

See sample: `job-queue-category-code-serializes-conflicting-jobs.good.al`.

## Anti Pattern

Creating or configuring multiple job queue entries that update the same exclusive resource while leaving their Job Queue Category Code empty or different. Do not flag jobs merely because they touch the same tables; the rule applies when their operation requires mutual exclusion.

See sample: `job-queue-category-code-serializes-conflicting-jobs.bad.al`.