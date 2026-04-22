---
bc-version: [1..99]
domain: finance
keywords: [codeunit-12, gen-jnl-post-line, journal-posting, high-risk, ledger-integrity]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Codeunit 12 (Gen. Jnl.-Post Line)

## Description

Codeunit 12 is the single posting engine for every journal line in Business Central. General journals, payment journals, cash receipt journals, recurring journals, IC journals, and the journal-like intermediaries used by document posting (Sales-Post, Purch.-Post, Invoice Post. Buffer) all funnel through this codeunit to produce G/L Entries, Customer Ledger Entries, Vendor Ledger Entries, Bank Account Ledger Entries, VAT Entries, and Detailed Ledger Entries. The entry numbering, dimension resolution, multi-currency math, and VAT computation for every posted line happen here.

Because every monetary posting passes through codeunit 12, any modification to its behaviour — even a seemingly local change to one sub-procedure — has repository-wide blast radius. A change intended to affect only Purchase posting will also hit Sales, General Journal, Intercompany, bank payments, and every extension that raises integration events on codeunit 12's publishers. Debugging an unexpected posting change across multiple modules frequently traces back here.

## Best Practice

Extend codeunit 12 only through the published integration events (`OnAfterPostGLAcc`, `OnAfterPostCustVendAccount`, etc.). Subscribing is additive and local to the subscriber; forking codeunit 12's body inside an extension loses access to Microsoft's future fixes.

## Anti Pattern

Modifying codeunit 12's core computation in a customisation to fix a reported issue. Every subsequent BC platform upgrade must merge around the modification, and the modification's side effects on other modules are rarely exhaustively tested. Use events.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "High-Risk Areas") on 2026-04-21.
