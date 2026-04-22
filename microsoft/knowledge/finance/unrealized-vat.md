---
bc-version: [1..99]
domain: finance
keywords: [unrealized-vat, vat-realization, payment-application, vat-entry, deferred-recognition]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Unrealized VAT

## Description

Unrealized VAT defers the VAT liability to the moment payment settles rather than the moment the invoice posts. When enabled on a VAT Posting Setup cell, posting the invoice creates a VAT Entry with a zero amount in the Amount column and the full amount in Unrealized Amount. When a payment applies to the invoice via codeunit 226 (`CustEntry-Apply Posted Entries`) or 227 (`VendEntry-Apply Posted Entries`), additional VAT Entries are created that move the amount from Unrealized to Realized in proportion to the payment applied. Partial payments realize partial VAT.

This matters for three reasons. First, the VAT return runs on realized entries only, so the period the liability is declared depends on payment date, not invoice date. Second, the chain of VAT Entries grows: one per application event. Third, reversing an application (un-applying entries) creates mirror VAT Entries that reverse the realization — never edit existing entries. The mechanism is well-defined; bugs usually stem from assumptions that VAT always realizes at posting.

## Best Practice

When migrating a company onto Unrealized VAT, take the effective-date approach: new invoices carry the new setup, historical open invoices post-realize at payment under the old setup. Mixing both setups on the same open invoice produces a VAT Entry chain that does not balance.

## Anti Pattern

Expecting the VAT account to equal the invoice's VAT amount immediately after the invoice posts. Under Unrealized VAT, the account is zero until the first payment applies. Reports that compare invoice VAT to G/L VAT balance must filter by realization state or they report every unpaid invoice as an error.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "VAT Calculation") on 2026-04-21.
