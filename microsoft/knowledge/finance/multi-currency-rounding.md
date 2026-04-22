---
bc-version: [1..99]
domain: finance
keywords: [multi-currency, rounding, currency-precision, invoice-rounding, fcy-lcy]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Multi-currency rounding

## Description

Every Currency record (table 4) declares four rounding precisions that govern how BC handles foreign-currency (FCY) amounts: Amount Rounding Precision (typically 0.01), Unit-Amount Rounding Precision (typically 0.00001, used for unit prices), Invoice Rounding Precision (typically 0.01, the tolerance that lets an invoice round to a "clean" final amount), and Appln. Rounding Precision (tolerance for closing applications across currencies). The four precisions interact with the local currency's precision to determine what amounts a document ends up posting.

At post time the codeunit computes three amounts per line: the FCY amount (rounded to Amount Rounding Precision), the LCY amount (FCY × exchange rate, rounded to the local currency's precision), and any residual that falls to the Invoice Rounding account configured on the Customer/Vendor Posting Group. Rounding conflicts appear when: (a) LCY precision is coarser than FCY — JPY bookkeeping with EUR documents rounds to whole yen but allows 0.01 EUR; (b) per-line rounding on a many-line document diverges from single-line rounding of the document total; (c) the exchange rate changes between an order's receipt and its invoice, and the rounding residual shifts.

## Best Practice

Use the Invoice Rounding account purposefully — set it to a dedicated G/L account so the residuals aggregate where finance can review them. A catch-all "other income" lumps them with real transactions and hides rounding drift.

## Anti Pattern

Disabling Invoice Rounding by setting the precision to 0. The residuals then split across every VAT and payment account, making period-end reconciliation a hunt for pennies that do not belong to any transaction.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "Multi-Currency — Rounding and Exchange Rates") on 2026-04-21.
