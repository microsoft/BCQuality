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

Posting a prepared revaluation batch through `"Item Jnl.-Post Batch"` preserves the calculated line's valuation date, aggregation scope, location/variant filters, and revaluation fields. The batch expands summarized values into per-entry postings and checks that the eligible inventory has not changed; for partial revaluation it also rechecks remaining quantity before posting.

The public `"Item Jnl.-Post Line".RunWithCheck` API does not replace that orchestration. It remains legitimate for finalized individual-entry revaluation lines within a workflow that already supplies the necessary checks; the batch itself uses the line poster. Ordinary quantity journals and finalized per-entry revaluations are distinct from this summarized/partial-revaluation case.

The samples explicitly require `"Value Entry Type" = Revaluation` and a nonblank `"Inventory Value Per"` in an existing calculated journal batch. They demonstrate posting, not how to calculate a new valuation or choose a standard cost.

See sample: [`post-revaluation-through-the-item-journal-batch.good.al`](post-revaluation-through-the-item-journal-batch.good.al).

## Anti Pattern

A loop that sends calculated aggregate revaluation lines straight to `"Item Jnl.-Post Line"` skips distribution over the underlying item entries. A partial-revaluation workflow without the remaining-quantity recheck can post a valuation against inventory that no longer matches the calculation.

Directly editing existing `"Value Entry"` cost amounts or the Item's unit cost does not repair those allocation and adjustment relationships. Their correction belongs to the revaluation/cost-adjustment workflow.

See sample: [`post-revaluation-through-the-item-journal-batch.bad.al`](post-revaluation-through-the-item-journal-batch.bad.al).

## References

- [Revaluation design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-revaluation)
- [Inventory posting design](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-inventory-posting)
- [BaseApp summarized revaluation and remaining-quantity checks](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Posting/ItemJnlPostBatch.Codeunit.al#L510-L714)
