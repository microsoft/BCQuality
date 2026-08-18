---
bc-version: [all]
domain: finance
keywords: [ledger-entry, immutable, reversal, audit-trail, correction, custentry-edit, non-financial-fields]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Correct posted ledger entries by reversing, not by editing or deleting them

## Description

A posted ledger entry is part of Business Central's permanent audit trail, and its **financial content** is immutable. The amounts, accounts, posting date, and quantities on `G/L Entry`, `Cust. Ledger Entry`, `Vendor Ledger Entry`, and similar tables must not change after posting, because registers, applications, VAT statements, and statutory reports all assume that content is append-only. Correcting financial content is therefore itself a posting: BC provides reversal (the `Reverse` / `Reverse Register` routines) and correcting documents (credit memos, correcting journals) that post a new, offsetting entry and leave the original intact. This immutability rule is about financial content — it is not a blanket ban on touching the entry (see Best Practice).

## Best Practice

To undo or correct a posting's **financial** content, post a reversing or correcting entry through the normal posting path so the offset is itself a balanced, dated, traceable transaction. The original entry stays in place and the two net to zero, preserving the audit trail.

Non-financial **operational** fields are a deliberate exception and are meant to be edited after posting. BC supports updating a defined set of post-posting fields — payment and application data such as due date, payment-discount dates, on-hold status, applies-to ID, and recipient/communication fields — and the Customer and Vendor Ledger Entries pages expose several of them as editable. Make those changes through the dedicated `CustEntry-Edit` / `VendEntry-Edit` routines (which those pages call), not a raw `Modify`, so the edit stays within the supported set and leaves the entry's financial content and audit trail intact.

## Anti Pattern

Calling `Modify` or `Delete` on a posted ledger entry to fix a mistake — changing an amount, repointing an account, or removing the row. Detection signal: `Modify`, `ModifyAll`, `Delete`, or `DeleteAll` on a `*Ledger Entry` or `G/L Entry` record outside a dedicated `*Entry-Edit` routine. This destroys the audit trail, desynchronizes the entry from its register and detailed entries, and corrupts any report or reconciliation that already consumed the original value.
