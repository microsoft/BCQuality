---
bc-version: [all]
domain: performance
keywords: [modifyall, deleteall, regression, triggers, media, security-filtering, companion-fields, subscriber, progress]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Triggers, subscribers, and media fields can silently regress ModifyAll / DeleteAll

## Description

`ModifyAll` and `DeleteAll` can limit SQL calls, but Microsoft documents that they [revert to individual calls](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/administration/optimize-sql-al-database-methods-and-performance-on-server#modifyall-and-deleteall) when the table has trigger code, related modify/delete/global/database event subscribers, active security filtering, `Media` or `MediaSet` fields, or fields added through companion tables. These conditions must be assessed from the target table and runtime context, not only from the visible bulk call.

## Best Practice

Before introducing a fallback condition, audit the `ModifyAll`/`DeleteAll` call sites that target the table and assess the regression cost. Once a bulk path already executes row by row, one explicit loop can be reasonable when it preserves the same trigger semantics and adds required per-row progress UX; consolidating several regressed bulk calls into one pass can also avoid repeated iteration. This is a narrow equivalence check, not a generic progress-dialog exemption: when no fallback condition applies, retain the bulk API.

## Anti Pattern

Adding a fallback condition to a hot table without auditing bulk-write call sites, or replacing a working bulk API with a per-row loop solely to show progress. The mirror anti-pattern is chaining several bulk calls on a table that already falls back, causing repeated row-by-row passes.
