---
bc-version: [1..99]
domain: finance
keywords: [entry-application, remaining-amount, payment-discount, payment-tolerance, codeunit-226, codeunit-227]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Entry application

## Description

Entry application is the mechanism by which payments close invoices, credit memos offset invoices, and refunds close credits. A customer ledger entry carries a Remaining Amount that tracks the unapplied balance; an application event (Apply Customer Entries / Apply Vendor Entries) reduces Remaining Amount on both sides of the application until one side hits zero. Codeunit 226 (`CustEntry-Apply Posted Entries`) handles customer applications; codeunit 227 (`VendEntry-Apply Posted Entries`) handles vendors. Both route through codeunit 12 for the G/L posting and write Detailed Cust./Vendor Ledger Entries that preserve the application history.

Two tolerances add flexibility. Payment Discount gives a counterparty a reduced amount if they pay within a grace window; when the payment matches the discounted amount, the invoice closes and a discount-expense G/L Entry records the difference. Payment Tolerance lets a slightly short payment still close an invoice; the shortfall posts to a Payment Tolerance account. Both are configured on the Sales & Receivables Setup and Vendor Posting Groups; both can be disabled per customer/vendor.

Applications across currencies trigger an exchange-rate adjustment inside the application itself: the FCY amounts apply directly, but the LCY equivalent of each leg may differ because the rates at posting dates differ. The difference posts to an exchange gain/loss account as part of the application, independent of the period-end Adjust Exchange Rates batch.

## Best Practice

Let the Apply action compute the amounts. Manually setting Amount to Apply on one side and letting the other auto-calculate produces rounding that can leave tiny (0.01) Remaining Amounts that block closing the period.

## Anti Pattern

Scripting direct updates to Remaining Amount to close out a balance. The Detailed Cust./Vendor Ledger Entry chain no longer matches and the entry, while appearing closed, cannot be un-applied or reversed cleanly.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "Entry Application") on 2026-04-21.
