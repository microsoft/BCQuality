---
bc-version: [1..99]
domain: finance
keywords: [chart-of-accounts, gl-account, account-category, account-subcategory, financial-reports]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Chart of Accounts

## Description

The Chart of Accounts (table 15 — `G/L Account`) is the backbone of Business Central's financial reporting. Every posting in the system, no matter where it originates, eventually produces G/L Entries against accounts defined here. The chart's structure determines what financial statements look like: accounts carry an Account Category (Assets, Liabilities, Equity, Income, Cost of Goods Sold, Expense) and an Account Subcategory that groups them for statement rows. Financial reports (balance sheet, income statement, trial balance) aggregate entries by these classifications rather than by the raw account numbers.

Because every sub-ledger (customer, vendor, item, fixed asset, bank) ultimately posts to G/L, the chart is the single integration point for all monetary movement. A miscategorised account shifts amounts between sections of the financial statements without producing a posting error — the numbers look fine at the account level and wrong at the statement level.

## Best Practice

Set Account Category and Account Subcategory on every G/L Account — do not leave them blank on new accounts. Run the financial report rebuild after restructuring the chart so the subcategory totals re-calculate against all historical entries.

## Anti Pattern

Using free-text Account Name as the only grouping signal. Reports that aggregate by name are brittle to typos and translation; category/subcategory are the authoritative grouping.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "Chart of Accounts & G/L Posting") on 2026-04-21. To be refined in Phase 2 from `D:\Repos\NAV\App\Layers\W1\BaseApp\Finance\`.
