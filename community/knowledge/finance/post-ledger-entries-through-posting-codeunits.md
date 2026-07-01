---
bc-version: [all]
domain: finance
keywords: [posting, g-l-entry, ledger-entry, gen-jnl-post-line, journal-line, balancing, entry-no]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Post ledger entries through the posting engine, never by inserting them directly

## Description

Ledger entries — `G/L Entry`, `Cust. Ledger Entry`, `Vendor Ledger Entry`, `Item Ledger Entry`, and their detailed counterparts — are the output of Business Central's posting engine, not ordinary tables an extension writes to. The supported way to create them is to populate a journal line (for example `Gen. Journal Line`) and run the matching posting codeunit (`Gen. Jnl.-Post Line`, codeunit 12, for general-ledger postings). The posting routine enforces double-entry balancing, allocates `Entry No.` safely under concurrency, creates the register, resolves dimensions, applies VAT, and links source and application data. None of that happens when a row is inserted into the ledger table directly.

## Best Practice

Build the transaction as one or more journal lines and hand them to the posting codeunit. Let the engine assign `Entry No.`, create the `G/L Register`, and write the balancing entries. When you need a reusable entry point, wrap the journal-line setup in your own codeunit but still post through `Gen. Jnl.-Post Line` — or through the document-posting routines (sales, purchase, service) that ultimately call it. See sample: `post-ledger-entries-through-posting-codeunits.good.al`.

## Anti Pattern

Calling `Insert` on a ledger table — typically after a `FindLast` to guess the next `Entry No.` Detection signal: any `Insert` on a `*Ledger Entry` or `G/L Entry` record, or an `Entry No.` computed in AL rather than returned by the platform. Such code produces an unbalanced, registerless, dimensionless row that reconciliation and reporting will treat as corrupt, and the hand-computed `Entry No.` races under concurrency. See sample: `post-ledger-entries-through-posting-codeunits.bad.al`.
