---
bc-version: [all]
domain: data-modeling
keywords: [posting-routine, check-line, post-line, post-batch, companion-codeunit, yes-no-wrapper, journal]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Split posting routines into Check Line / Post Line / Post Batch

> Contributions welcome — open a PR to refine or extend this article.

## Description

Business Central's own journal-based posting routines consistently follow a three-codeunit split with distinct, non-overlapping responsibilities — `Codeunit "Gen. Jnl.-Check Line"` / `"Gen. Jnl.-Post Line"` / `"Gen. Jnl.-Post Batch"` for the general journal, and the same `<Journal>-Check Line` / `<Journal>-Post Line` / `<Journal>-Post Batch` shape repeated for Item, Resource, Job, Fixed Asset, Insurance, and Cost Accounting journals: `Check Line` validates one line, `Post Line` writes exactly one line to the ledger, and `Post Batch` loops both across the journal. A document posting routine (posting one document at a time) calls `Post Line` directly and skips `Post Batch`. This is the standard shape to evaluate a new journal-based posting routine against, not a platform-enforced constraint — a routine with a genuinely different transaction/reuse shape may legitimately organize itself differently. But a new routine that blurs this split without a specific reason either misses functionality other code expects to call directly, or exposes an interaction surface it shouldn't.

## Best Practice

`Check Line` reads setup/dimension data only on its first call and shows no UI beyond errors. `Post Line` only operates on the record passed to it — never the Journal table — so it can be called directly by other posting code, including a document posting routine. `Post Batch` is the only one of the three that reads and updates the Journal table, and it is the only one invoked from the Post action on a journal page. A `-Post` document codeunit is never called directly from a page; a page calls a `-Post (Yes/No)` confirmation wrapper instead, so the same `-Post` codeunit can also run unattended from a batch-posting report.

See sample: `check-post-line-batch-pattern.good.al`.

## Anti Pattern

A single monolithic posting codeunit that reads the Journal table, validates lines, writes ledger entries, and shows confirmation dialogs all in one procedure. It cannot be reused by another posting routine without fabricating journal records, and it cannot run unattended because it insists on user interaction.

See sample: `check-post-line-batch-pattern.bad.al`.
