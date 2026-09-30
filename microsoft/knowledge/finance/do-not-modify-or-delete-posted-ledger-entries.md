---
bc-version: [all]
domain: finance
keywords: [g-l-entry, ledger-entry, reversal, audit-trail, correction, financial-content, entry-edit]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Correct posted financial content through posting workflows, not row surgery

## Description

Changing a posted entry's original amount, account, posting date, or tax amounts in place does not correct the related ledger, register, or source document. Deleting one erroneous row has the same problem. Business Central provides reversing and correcting posting workflows that retain the relationship between the original transaction and its correction; this is not a blanket prohibition on every write to a posted table.

## Best Practice

Use a supported transaction/register reversal, credit memo, or correcting journal appropriate to the original posting and its current state. Request the standard reversal workflow rather than negating a single row or setting `Reversed` yourself. Let that workflow enforce eligibility; do not change source or application fields to make a rejected reversal pass.

Supported operational edits are deliberate exceptions: for example, `"G/L Entry-Edit"` supports description changes, and `"Cust. Entry-Edit"` / `"Vend. Entry-Edit"` handle their table-specific editable fields. [Due-date synchronization](change-ledger-due-dates-through-entry-edit.md), [application/unapplication](apply-ledger-entries-through-application-codeunits.md), G/L dimension correction, and supported date compression have their own workflows. Do not flag their standard implementations, temporary simulation buffers, or extension-only metadata updates as financial row surgery. A subscriber is not exempt merely because it runs inside a supported workflow: inspect the fields it actually changes.

This rule covers G/L, customer/vendor/detailed, VAT, and financial-posting/register records. Item, Value, Capacity, Warehouse, inventory-application, and other inventory-posting records are SCM concerns. The financial-row leg of one inventory-posting bypass is outside this rule when the same inventory correction resolves it; an independently actionable financial defect remains in scope regardless of the containing module's name.

See sample: [`do-not-modify-or-delete-posted-ledger-entries.good.al`](do-not-modify-or-delete-posted-ledger-entries.good.al).

## Anti Pattern

Persist a change to original financial content, delete posted rows, or fabricate reversal flags/links to repair or undo a transaction outside the supported correction/maintenance workflow. Require an existing, non-temporary Finance-owned record and evidence of the fields or rows affected; a `Modify` token or `*Ledger Entry` name alone is insufficient. Settlement-state writes belong to the application article rather than a duplicate finding here.

See sample: [`do-not-modify-or-delete-posted-ledger-entries.bad.al`](do-not-modify-or-delete-posted-ledger-entries.bad.al).

## References

- [Reverse journal postings](https://learn.microsoft.com/en-us/dynamics365/business-central/finance-how-reverse-journal-posting).
- [Correct G/L dimensions](https://learn.microsoft.com/en-us/dynamics365/business-central/finance-troubleshooting-correcting-dimensions).
- [BCApps: G/L Entry-Edit](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Finance/GeneralLedger/Ledger/GLEntryEdit.Codeunit.al).
- [BCApps: supported customer-ledger date compression](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Sales/Receivables/DateCompressCustomerLedger.Report.al).
