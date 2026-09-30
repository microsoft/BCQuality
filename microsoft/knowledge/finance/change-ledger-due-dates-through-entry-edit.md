---
bc-version: [all]
domain: finance
keywords: [due-date, initial-entry-due-date, cust-entry-edit, vend-entry-edit, detailed-ledger-entry, aging]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Change posted customer/vendor due dates through the entry-edit workflow

## Description

A posted customer or vendor due date is supported editable operational data, but it is also represented by `Initial Entry Due Date` on related detailed ledger entries. Validating `Due Date` and calling `Modify(true)` on the main entry does not perform all synchronization done by `"Cust. Entry-Edit"` or `"Vend. Entry-Edit"`. The main entry and due-date-based analysis can otherwise disagree.

## Best Practice

Fetch the existing entry, validate the proposed `Due Date`, and pass the changed record to the corresponding entry-edit codeunit, as the standard ledger pages do. Field validation enforces entry-state rules; the editor persists the supported change and synchronizes related detailed entries. Preserve both steps rather than treating table triggers as equivalent to the edit workflow.

This is a due-date synchronization rule, not a prohibition on all operational edits after posting. Exclude temporary buffers, extension-only fields, supported editor internals, and code that demonstrably performs the equivalent synchronization under the supported workflow. Check the actual table/routine instead of assuming every `*Entry-Edit` accepts the same fields.

See sample: [`change-ledger-due-dates-through-entry-edit.good.al`](change-ledger-due-dates-through-entry-edit.good.al).

## Anti Pattern

Change `Due Date` on an existing non-temporary `Cust. Ledger Entry` or `Vendor Ledger Entry` and persist it with `Modify`, `Modify(true)`, or `ModifyAll` without the edit workflow or equivalent related-entry update. A preceding `Validate("Due Date", ...)` is not sufficient evidence of synchronization.

See sample: [`change-ledger-due-dates-through-entry-edit.bad.al`](change-ledger-due-dates-through-entry-edit.bad.al).

## References

- [Cust. Entry-Edit API](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/codeunit/microsoft.sales.receivables.cust.-entry-edit).
- [Vend. Entry-Edit API](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/codeunit/microsoft.purchases.payables.vend.-entry-edit).
- [BCApps: customer due-date synchronization](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Sales/Receivables/CustEntryEdit.Codeunit.al).
- [BCApps: vendor due-date synchronization](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Purchases/Payables/VendEntryEdit.Codeunit.al).
