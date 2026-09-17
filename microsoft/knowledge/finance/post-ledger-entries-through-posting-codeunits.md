---
bc-version: [all]
domain: finance
keywords: [g-l-entry, ledger-entry, gen-jnl-post-line, gen-jnl-post-batch, journal-line, register, insert]
technologies: [al]
countries: [w1]
application-area: [finance]
---

# Create financial ledger entries through the owning posting engine

## Description

Standard financial ledger entries are outputs of posting, not independent rows an extension manufactures. Even two manually inserted G/L rows with balanced amounts bypass posting checks, register bookkeeping, and transaction/source relationships. `G/L Entry.Insert(true)` runs the table trigger; it does not invoke the posting engine.

## Best Practice

Use the owning document or journal posting workflow. For a normal persisted general-journal batch, use `"Gen. Jnl.-Post Batch"`; the example posts an existing batch containing one self-balancing, non-VAT G/L transfer. Let posting allocate entries and maintain the register rather than reconstructing its tables.

`"Gen. Jnl.-Post Line".RunWithCheck` is appropriate for a complete journal line inside a correctly owned posting lifecycle, but it does not invent a balancing account or document number, allocate numbering merely from `Posting No. Series`, or replace [batch document-balancing policy](preserve-journal-batch-document-balance.md). The line codeunit is stateful; its checked wrapper owns its start/continue/finish work. Normal batch posting owns its numbering and commits by default; do not imply these entry points are transaction-neutral.

Exclude temporary buffers and the standard engine's own insertion points. A checked parent may legitimately use `RunWithoutCheck`; do not replace it without inspecting that parent. This rule concerns standard financial ledgers, not a custom table merely named `Ledger Entry` or a supported, specifically reviewed migration/repair workflow.

See sample: [`post-ledger-entries-through-posting-codeunits.good.al`](post-ledger-entries-through-posting-codeunits.good.al).

## Anti Pattern

Create posted financial effects by directly inserting persistent `G/L Entry`, customer/vendor ledger, or VAT ledger rows outside their owning posting workflow. Resolve the actual record type and lifecycle. Balanced debit/credit values, copied dimensions, `Insert(true)`, and a lock around entry-number allocation do not turn raw inserts into a complete posting.

See sample: [`post-ledger-entries-through-posting-codeunits.bad.al`](post-ledger-entries-through-posting-codeunits.bad.al).

## References

- [Posting engine structure](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-posting-engine-structure).
- [Gen. Jnl.-Post Line API](https://learn.microsoft.com/en-us/dynamics365/business-central/application/base-application/codeunit/microsoft.finance.generalledger.posting.gen.-jnl.-post-line).
- [BCApps: posting lifecycle and register maintenance](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Finance/GeneralLedger/Posting/GenJnlPostLine.Codeunit.al).
