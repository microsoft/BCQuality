---
bc-version: [all]
domain: scm
keywords: [warehouse-adjustment, calculate-whse-adjustment, adjustment-bin-code, directed-put-away-and-pick, item-journal-line, warehouse-entry]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reconcile warehouse adjustments with the item ledger

## Description

At a Directed Put-away and Pick location, registering an ordinary warehouse quantity or physical-inventory adjustment and synchronizing it to inventory are distinct steps. The warehouse registration balances quantity through the adjustment bin. An additional ordinary item-journal increase/decrease is not the same as consuming that pending warehouse adjustment.

## Best Practice

After the warehouse adjustment has been registered, run `"Calculate Whse. Adjustment"` for the intended item/location and prepared item-journal batch, then post the generated lines through `"Item Jnl.-Post Batch"`. The calculation derives the reconciliation by location, variant, units of measure, and tracking, marks the lines `"Warehouse Adjustment"`, and accounts for already prepared unposted adjustments.

Keep reconciliation separate from source-document posting: warehouse receipts/shipments use their document workflows. Intentional warehouse-only staging is valid when a separately owned reconciliation step completes the process; do not flag the registration call just because that later job is outside the diff.

Do not generalize this rule to every warehouse operation. Bin movements need not change total inventory, and warehouse tracking/expiration reclassification has a standard batch path that can also post item-journal entries. Standard reclassification and basic-location item adjustments are not this ordinary advanced-warehouse quantity-adjustment case.

The samples start after warehouse quantity registration and report whether inventory reconciliation completed. The clean sample calculates and posts into an empty dedicated batch; it is not a complete warehouse physical-count workflow.

## Anti Pattern

Report a workflow that claims to reconcile a registered advanced-warehouse quantity adjustment by posting a manually mirrored ordinary item-journal line, or that marks reconciliation complete after only warehouse registration or adjustment calculation. Calculation prepares journal lines; it does not post those lines. Require explicit synchronization intent and location/workflow evidence.

Do not repair the defect by inventing positive/negative quantities or flipping `"Warehouse Adjustment"` on an arbitrary line. Use the calculation step so the adjustment-bin balance and the actual tracked quantities drive inventory reconciliation.

## Samples

- [`reconcile-warehouse-adjustments-with-the-item-ledger.bad.al`](reconcile-warehouse-adjustments-with-the-item-ledger.bad.al)
- [`reconcile-warehouse-adjustments-with-the-item-ledger.good.al`](reconcile-warehouse-adjustments-with-the-item-ledger.good.al)

## References

- [Synchronize adjusted warehouse entries with item ledger entries](https://learn.microsoft.com/en-us/dynamics365/business-central/inventory-how-count-adjust-reclassify#to-synchronize-the-adjusted-warehouse-entries-with-the-related-item-ledger-entries)
- [BaseApp warehouse-adjustment calculation](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Warehouse/Journal/CalculateWhseAdjustment.Report.al#L298-L384)
- [Warehouse reclassification exception](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Warehouse/Journal/WhseJnlRegisterBatch.Codeunit.al#L196-L210)
