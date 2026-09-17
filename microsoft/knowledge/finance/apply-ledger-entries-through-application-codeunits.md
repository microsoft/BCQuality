---
bc-version: [all]
domain: finance
keywords: [cust-ledger-entry, vendor-ledger-entry, detailed-ledger-entry, remaining-amount, application, unapplication, open, closed-by-entry-no]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Apply and unapply entries through the application workflow, not status flags

## Description

Customer/vendor settlement is a posting operation involving detailed ledger entries, not just a change to `Open` on the main entry. Remaining amounts are calculated from detailed entries. Unapplication posts correcting entries and handles application-derived effects such as discounts and currency gains/losses; deleting details or changing `Unapplied` cannot reproduce that history.

## Best Practice

Use `"CustEntry-Apply Posted Entries"` / `"VendEntry-Apply Posted Entries"` and the supported application or unapplication workflow. Let it check application dates, entry state, and application ordering. The `ApplyCustEntryFormEntry` / `ApplyVendEntryFormEntry` and `UnApply...LedgEntry` methods are **interactive**: users select and confirm the operation. They are not unattended "mark paid" APIs.

For programmatic posting, use the target version's public `Apply` / `PostUnApply...` APIs with properly prepared selection and `Apply Unapply Parameters`; handle cancellation and the workflow's transaction/commit behavior. `"Applying Entry"`, `"Applies-to ID"`, and `"Amount to Apply"` are legitimate application-preparation fields. Do not report their writes alone, temporary buffers, supported posting/compression internals, or unrelated operational/extension fields.

See sample: [`apply-ledger-entries-through-application-codeunits.good.al`](apply-ledger-entries-through-application-codeunits.good.al).

## Anti Pattern

Implement payment matching, settlement, or reopening by directly persisting `Open`, `"Closed by Entry No."`, closure amounts/dates, or detailed-entry unapplication flags, or by deleting/rewriting detailed application amounts. Require confirmed writes to existing non-temporary records and settlement intent. Do not suggest assigning a `Remaining Amount` FlowField as a fix.

This article owns fabricated application state. Use the [posted-financial-content rule](do-not-modify-or-delete-posted-ledger-entries.md) for original accounting-value corrections, not a second finding prescribing the same application fix.

See sample: [`apply-ledger-entries-through-application-codeunits.bad.al`](apply-ledger-entries-through-application-codeunits.bad.al).

## References

- [Apply and unapply customer transactions](https://learn.microsoft.com/en-us/dynamics365/business-central/receivables-how-apply-sales-transactions-manually).
- [Apply and unapply vendor transactions](https://learn.microsoft.com/en-us/dynamics365/business-central/payables-how-apply-purchase-transactions-manually).
- [BCApps: customer application workflow](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Sales/Receivables/CustEntryApplyPostedEntries.Codeunit.al).
- [BCApps: vendor application workflow](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Purchases/Payables/VendEntryApplyPostedEntries.Codeunit.al).
