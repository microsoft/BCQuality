---
bc-version: [all]
domain: scm
keywords: [requisition-line, action-message, accept-action-message, req-wksh-make-order, carryoutbatchaction, demand-order-no, planning-flexibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Carry out requisition actions through the standard workflow

## Description

A requisition/planning line is a pending change to a supply/demand network, not just a template for a purchase line. Carry-out interprets New, change-quantity, reschedule, and cancel actions, preserves referenced supply and planning flexibility, and moves reservation/tracking ownership before finalizing the proposal. Creating a plausible purchase order and deleting the requisition line can leave new supply unrelated to the demand that caused it.

## Best Practice

For requisition batch carry-out, initialize `"Req. Wksh.-Make Order"` with `Set` and invoke `CarryOutBatchAction` on the intended accepted lines. Supply the order/posting/receipt defaults separately from the ending-order-date cutoff, and preserve the selected worksheet/batch/line filters. A plain `Run` or a single order-line insertion helper is not a replacement for this batch initialization and finalization.

Use the standard `"Carry Out Action"` dispatch for broader planning output and its configured purchase, transfer, assembly, or manufacturing choices. Do not turn every action into a new purchase order, bypass source-specific reservation transfer, or delete proposals before the owning workflow has completed their supply change.

Ordinary manual purchase creation that does not consume planning output is outside this rule. Users may reject or delete unwanted proposals without creating supply; temporary planning simulations, pre-carry-out enrichment, and engine-owned cleanup are also legitimate. `Delete(true)` on a requisition line is not intrinsically a defect.

The samples select an existing accepted New/Purchase item proposal with sales-demand context. Dates are explicit, the source selection remains bounded, and the clean sample leaves order creation and reservation handoff to the standard workflow; it is not a complete planning-run generator.

## Anti Pattern

Report code that consumes accepted persistent `"Requisition Line"` action messages, manually creates or changes supply from a subset of fields, and then deletes or marks the proposal handled without the standard carry-out/source-reservation handoff. Running purchase-field validation and the requisition delete trigger does not first move the proposal's demand links to the new purchase line.

Require both proposal-consumption intent and a visible supply conversion. Do not flag an isolated deletion of an unwanted suggestion, an ordinary purchase-order API, or the standard carry-out engine's own insert/delete sequence.

## Samples

- [`carry-out-requisition-actions-through-the-standard-workflow.bad.al`](carry-out-requisition-actions-through-the-standard-workflow.bad.al)
- [`carry-out-requisition-actions-through-the-standard-workflow.good.al`](carry-out-requisition-actions-through-the-standard-workflow.good.al)

## References

- [Perform planning action messages](https://learn.microsoft.com/en-us/dynamics365/business-central/production-how-to-run-mps-and-mrp#to-perform-action-messages)
- [Planning functionality](https://learn.microsoft.com/en-us/dynamics365/business-central/production-about-planning-functionality)
- [Reservation, order tracking, and action messaging](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-reservation-order-tracking-and-action-messaging)
- [BaseApp carry-out caller and date defaults](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Requisition/CarryOutActionMsgReq.Report.al#L116-L133)
- [Batch initialization and selection](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Requisition/ReqWkshMakeOrder.Codeunit.al#L116-L215)
- [Reservation handoff before supply finalization](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Requisition/ReqWkshMakeOrder.Codeunit.al#L663-L743)
