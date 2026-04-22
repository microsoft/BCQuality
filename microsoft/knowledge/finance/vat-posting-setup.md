---
bc-version: [1..99]
domain: finance
keywords: [vat, vat-posting-setup, vat-business-group, vat-product-group, reverse-charge, full-vat]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# VAT posting setup

## Description

VAT Posting Setup (table 325) is the matrix that tells Business Central how to compute VAT for every combination of VAT Business Posting Group (who the counterparty is — domestic, EU, export) and VAT Product Posting Group (what is being transacted — standard goods, reduced-rate goods, exempt services). Each cell of the matrix declares the VAT % and the VAT Calculation Type that applies when that combination appears on a posting.

Three calculation types cover the common cases. Normal VAT applies the rate as a percentage of the line amount — the standard sales/purchase tax path. Reverse Charge VAT records the VAT on both sides of the transaction without a cash movement; the buyer, not the seller, is responsible for remitting it to the authority. Full VAT treats the entire line amount as VAT with no underlying taxable base — used for VAT-only correction documents. Every posted line in the document flows through the matching cell; misconfigured cells produce posting errors, incorrect returns, or off-balance VAT accounts.

## Best Practice

Populate the full matrix, including "not applicable" cells (with zero rate and a note). Missing cells produce an error message that names the combination the user tried to use, which is clearer than an unexpected zero-rate post that would mask the misconfiguration.

## Anti Pattern

Creating a single catch-all VAT Business Group for "everyone" and a single VAT Product Group for "everything." Reporting the VAT return later becomes impossible because every transaction collapses into one cell; the Authority requires transaction-level breakdown.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "VAT Calculation") on 2026-04-21. To be refined in Phase 2 from `D:\Repos\NAV\App\Layers\W1\BaseApp\Finance\VAT\`.
