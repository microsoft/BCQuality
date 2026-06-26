---
bc-version: [all]
domain: finance
keywords: [ledger-entry, immutable, reversal, audit-trail, correction, reverse, custentry-edit]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Correct posted ledger entries by reversing, not by editing or deleting them

## Description

A posted ledger entry is an immutable record in Business Central's audit trail. The financial content of `G/L Entry`, `Cust. Ledger Entry`, `Vendor Ledger Entry`, and similar tables — amounts, accounts, posting date, quantities — must not change after posting, because registers, applications, VAT statements, and statutory reports all assume entries are append-only. Corrections are themselves postings: BC provides reversal (the `Reverse` / `Reverse Register` routines) and correcting documents (credit memos, correcting journals) that post a new, offsetting entry and leave the original intact.

## Best Practice

To undo or correct a posting, post a reversing or correcting entry through the normal posting path so the offset is itself a balanced, dated, traceable transaction. The original entry stays in place and the two net to zero, preserving the audit trail. A narrow set of non-financial fields (for example an entry's `Open` / `On Hold` status or a due date) is editable through dedicated platform routines such as `CustEntry-Edit` and `VendEntry-Edit`; use those routines rather than a raw `Modify`.

## Anti Pattern

Calling `Modify` or `Delete` on a posted ledger entry to fix a mistake — changing an amount, repointing an account, or removing the row. Detection signal: `Modify`, `ModifyAll`, `Delete`, or `DeleteAll` on a `*Ledger Entry` or `G/L Entry` record outside a dedicated `*Entry-Edit` routine. This destroys the audit trail, desynchronizes the entry from its register and detailed entries, and corrupts any report or reconciliation that already consumed the original value.
