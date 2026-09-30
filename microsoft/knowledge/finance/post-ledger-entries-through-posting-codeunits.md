---
bc-version: [all]
domain: finance
keywords: [g-l-entry, ledger-entry, gen-jnl-post-line, gen-jnl-post-batch, journal-line, register, insert]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Create financial ledger entries through the owning posting engine

## Description

Standard financial ledger entries are outputs of posting, not independent rows an extension manufactures. Even two manually inserted G/L rows with balanced amounts bypass posting checks, register bookkeeping, and transaction/source relationships. `G/L Entry.Insert(true)` runs the table trigger; it does not invoke the posting engine.

## Best Practice

Use the owning document or journal posting workflow. For a normal persisted general-journal batch, use `"Gen. Jnl.-Post Batch"`; the example posts an existing batch containing one self-balancing, non-VAT G/L transfer. Let posting allocate entries and maintain the register rather than reconstructing its tables.

`"Gen. Jnl.-Post Line".RunWithCheck` is appropriate for a complete journal line inside a correctly owned posting lifecycle, but it does not invent a balancing account or document number, allocate numbering merely from `Posting No. Series`, or replace [batch document-balancing policy](preserve-journal-batch-document-balance.md). The line codeunit is stateful; its checked wrapper owns its start/continue/finish work. Normal batch posting owns its numbering and commits by default; do not imply these entry points are transaction-neutral.

Exclude temporary buffers and the standard engine's own insertion points. A checked parent may legitimately use `RunWithoutCheck`; do not replace it without inspecting that parent. This rule owns `G/L Entry`, `Cust. Ledger Entry`, `Vendor Ledger Entry`, their detailed customer/vendor entries, `VAT Entry`, and financial-posting/register records, not a custom table merely named `Ledger Entry` or a supported, specifically reviewed migration/repair workflow.

`Item Ledger Entry`, `Value Entry`, Capacity/Warehouse entries, `Item Application Entry`, and other inventory-posting records are SCM concerns, not this rule's financial-ledger scope. That exclusion includes the financial-row leg of a single inventory-posting bypass when restoring the inventory workflow corrects the whole operation. Distinct, independently actionable financial defects remain in scope.

See sample: [`post-ledger-entries-through-posting-codeunits.good.al`](post-ledger-entries-through-posting-codeunits.good.al).

## Anti Pattern

Create posted financial effects by directly inserting the Finance-owned records named above outside their owning posting workflow. Resolve the actual record type, operation, and lifecycle; do not match `*Ledger Entry` as a wildcard. Balanced debit/credit values, copied dimensions, `Insert(true)`, and a lock around entry-number allocation do not turn raw inserts into a complete posting.

See sample: [`post-ledger-entries-through-posting-codeunits.bad.al`](post-ledger-entries-through-posting-codeunits.bad.al).

## References

- [Posting engine structure](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-posting-engine-structure).
- [Gen. Jnl.-Post Line API](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/codeunit/microsoft.finance.generalledger.posting.gen.-jnl.-post-line).
- [BCApps: posting lifecycle and register maintenance](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Finance/GeneralLedger/Posting/GenJnlPostLine.Codeunit.al).
