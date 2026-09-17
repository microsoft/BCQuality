---
bc-version: [all]
domain: scm
keywords: [revaluation, inventory-value-per, partial-revaluation, item-jnl-post-batch, item-journal-line, runwithcheck, standard-cost]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Post calculated revaluation through the item journal batch

## Description

A calculated revaluation line with nonblank `"Inventory Value Per"` represents an aggregate, not a finalized posting against one item ledger entry. Codeunit `"Item Jnl.-Post Batch"` distributes that value over eligible entries, handles rounding, and coordinates Item/SKU standard-cost updates. Calling the line poster directly skips that batch work even though the input is a valid `"Item Journal Line"`.

## Best Practice

Post a prepared revaluation batch through `"Item Jnl.-Post Batch"`. Keep the calculated line's valuation date, aggregation scope, location/variant filters, and revaluation fields intact. The batch expands summarized values into per-entry postings and checks that the eligible inventory has not changed; for partial revaluation it also rechecks remaining quantity before posting.

Do not treat the public `"Item Jnl.-Post Line".RunWithCheck` API as a replacement for that orchestration. It remains legitimate for finalized individual-entry revaluation lines within a workflow that already supplies the necessary checks; the batch itself uses the line poster. A call to that API without evidence of summarized or partial revaluation is not this defect.

The samples explicitly require `"Value Entry Type" = Revaluation` and a nonblank `"Inventory Value Per"` in an existing calculated journal batch. They demonstrate posting, not how to calculate a new valuation or choose a standard cost.

## Anti Pattern

Report a loop that sends calculated aggregate revaluation lines straight to `"Item Jnl.-Post Line"`, or a custom partial-revaluation workflow that bypasses the remaining-quantity recheck visible in the standard batch. A loop over the journal is not equivalent to distributing the aggregate over its underlying item entries.

Do not recommend directly editing existing `"Value Entry"` cost amounts or the Item's unit cost to repair the result. Use the revaluation/cost-adjustment workflow appropriate to the correction.

## Samples

- [`post-revaluation-through-the-item-journal-batch.bad.al`](post-revaluation-through-the-item-journal-batch.bad.al)
- [`post-revaluation-through-the-item-journal-batch.good.al`](post-revaluation-through-the-item-journal-batch.good.al)

## References

- [Revaluation design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-revaluation)
- [Inventory posting design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-inventory-posting)
- [BaseApp summarized revaluation and remaining-quantity checks](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Posting/ItemJnlPostBatch.Codeunit.al#L510-L714)
