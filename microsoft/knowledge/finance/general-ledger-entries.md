---
bc-version: [1..99]
domain: finance
keywords: [gl-entry, ledger, posting, subledger, immutable]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# General Ledger entries

## Description

G/L Entries (table 17) are the ultimate destination of every monetary posting in Business Central. Every sub-ledger entry — Customer Ledger Entry (21), Vendor Ledger Entry (25), Item Ledger Entry (32), Fixed Asset Ledger Entry (5601), Bank Account Ledger Entry (271) — produces corresponding G/L Entries that update account balances. The sub-ledgers exist to carry dimension-specific analytical data (due date, item number, reservation); G/L Entries are the canonical financial record.

G/L Entries are immutable. Reversing a mistake requires a corrective posting (often via `Reverse` on the original entry), not modification. The Entry No. column is monotonically increasing, so applications ordering entries by Entry No. see insertion order; they should not assume any relationship between Entry No. and Posting Date.

## Best Practice

When reading G/L Entries in a report, filter on Posting Date and Global Dimension 1/2 Code rather than on numeric Entry No. ranges — ranges are not stable across companies and break when entries are reversed and re-posted.

## Anti Pattern

Modifying G/L Entry columns directly in custom code to "fix" a posting error. The sub-ledger entries and supporting tables (Detailed Cust./Vendor Ledger Entry, VAT Entry) remain unchanged and diverge from G/L, producing an off-balance state that only surfaces at period-close reconciliation.

## Provenance

Migrated from microsoft/BCAppsTriage's `plugins/triage/skills/triage/references/area-knowledge/finance.md` (section: "Chart of Accounts & G/L Posting") on 2026-04-21. To be refined in Phase 2 from `D:\Repos\NAV\App\Layers\W1\BaseApp\Finance\`.
