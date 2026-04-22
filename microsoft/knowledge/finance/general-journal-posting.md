---
bc-version: [1..99]
domain: finance
keywords: [general-journal, journal-line, journal-posting, journal-types, gen-jnl-post-line]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# General journal posting

## Description

Journal posting is the freeform pathway into G/L. A user fills lines in a journal batch (table 81 — `Gen. Journal Line`) and runs post; codeunit 12 (`Gen. Jnl.-Post Line`) processes each line into the appropriate ledger entries. The same table serves several journal types, distinguished by their template/batch combination: General (generic postings), Payment (outgoing payments with applying logic), Cash Receipt (incoming payments with applying logic), Recurring (allocations and accruals with date formulas), and IC General (intercompany variants that replicate to partner companies).

Before the post, codeunit 13 (`Gen. Jnl.-Check Line`) validates each line — balancing, dimensions, account existence, posting restrictions. A failure there halts the entire batch; partial posts are not possible within a balanced transaction set. A single journal batch may contain many balanced transactions; each transaction is identified by a matching Document No. and must balance to zero across debits and credits.

## Best Practice

Separate unrelated postings into distinct balanced transactions (distinct Document No. values) within the batch. This makes a failure easier to locate and lets un-failed transactions still post if the check is run line-by-line.

## Anti Pattern

Stacking many unrelated postings under one Document No. A single validation error then blocks everything and the user must hunt for the offending line inside the balanced group.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "Chart of Accounts & G/L Posting") on 2026-04-21. To be refined in Phase 2 from `D:\Repos\NAV\App\Layers\W1\BaseApp\Finance\`.
