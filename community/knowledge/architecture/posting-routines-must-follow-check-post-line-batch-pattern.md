---
bc-version: [all]
domain: architecture
keywords: [posting-routine, check-line, post-line, post-batch, companion-codeunit, sales-post, yes-no-wrapper, journal]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Posting routines must follow the Check Line / Post Line / Post Batch pattern

> Contributions welcome — open a PR to refine or extend this article.

## Description
Every journal-based posting routine in Business Central is split across three companion codeunits with distinct, non-overlapping responsibilities: `<X> Check Line` validates one line and shows no UI beyond errors; `<X> Post Line` writes exactly one line to the ledger/register tables and never touches the Journal table itself, which is what lets other posting code call it directly; `<X> Post Batch` is the only one of the three that reads and updates the Journal table, looping Check Line then Post Line across all lines. A document posting routine (such as `Sales-Post`) calls `Post Line` directly per document and bypasses `Post Batch` entirely. A new posting routine that conflates these responsibilities, or a page that calls a `-Post` codeunit directly instead of through its `-Post (Yes/No)` confirmation wrapper, breaks assumptions other extensions and unattended batch-posting reports rely on.

## Best Practice
Keep `Check Line` free of side effects beyond validation and a first-call-only re-read of setup data; keep `Post Line` operating purely on the record variable it's given, never on the Journal table, so other posting code can call it without fabricating a journal line first; let only `Post Batch` read and write the Journal table. Route every page-initiated post through a `-Post (Yes/No)` wrapper that confirms with the user and then calls the interaction-free `-Post` codeunit, so the same posting logic stays safely callable from an unattended batch report.

## Anti Pattern
A `Post Line` codeunit that reads back from the Journal table, or a `Check Line` codeunit that writes to the database on every call, has taken on its neighbor's responsibility and can no longer be reused safely by other posting code. A page wired directly to a `-Post` codeunit — skipping the `-Post (Yes/No)` wrapper — either shows no confirmation to the user, or, if confirmation is bolted onto the core codeunit instead, makes that codeunit impossible to call from an unattended process.
