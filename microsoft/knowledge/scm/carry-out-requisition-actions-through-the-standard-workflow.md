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

Requisition batch carry-out initializes `"Req. Wksh.-Make Order"` with `Set` and invokes `CarryOutBatchAction` on the intended accepted lines. Order/posting/receipt defaults are separate from the ending-order-date cutoff, and worksheet/batch/line filters define the selection. A plain `Run` or a single order-line insertion helper is not a replacement for this batch initialization and finalization.

The standard `"Carry Out Action"` dispatch handles broader planning output and its configured purchase, transfer, assembly, or manufacturing choices. Each action's supply change and source-specific reservation transfer precede proposal finalization; not every action creates a new purchase order.

Ordinary manual purchase creation that does not consume planning output is outside this rule. Users may reject or delete unwanted proposals without creating supply; temporary planning simulations, pre-carry-out enrichment, and engine-owned cleanup are also legitimate. `Delete(true)` on a requisition line is not intrinsically a defect.

The samples select an existing accepted New/Purchase item proposal with sales-demand context. Dates are explicit, the source selection remains bounded, and the clean sample leaves order creation and reservation handoff to the standard workflow; it is not a complete planning-run generator.

See sample: [`carry-out-requisition-actions-through-the-standard-workflow.good.al`](carry-out-requisition-actions-through-the-standard-workflow.good.al).

## Anti Pattern

Manually creating or changing supply from a subset of an accepted persistent `"Requisition Line"`, then deleting or marking that proposal handled, skips the standard carry-out/source-reservation handoff. Purchase-field validation and the requisition delete trigger do not first move the proposal's demand links to the new purchase line.

Deleting an unwanted suggestion or creating an ordinary purchase order without consuming planning output is a separate operation. The standard carry-out engine's own insert/delete sequence participates in the source handoff rather than replacing it.

See sample: [`carry-out-requisition-actions-through-the-standard-workflow.bad.al`](carry-out-requisition-actions-through-the-standard-workflow.bad.al).

## References

- [Perform planning action messages](https://learn.microsoft.com/en-us/dynamics365/business-central/production-how-to-run-mps-and-mrp#to-perform-action-messages)
- [Planning functionality](https://learn.microsoft.com/en-us/dynamics365/business-central/production-about-planning-functionality)
- [Reservation, order tracking, and action messaging](https://learn.microsoft.com/en-us/dynamics365/business-central/design-details-reservation-order-tracking-and-action-messaging)
- [BaseApp carry-out caller and date defaults](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Requisition/CarryOutActionMsgReq.Report.al#L116-L133)
- [Batch initialization and selection](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Requisition/ReqWkshMakeOrder.Codeunit.al#L116-L215)
- [Reservation handoff before supply finalization](https://github.com/microsoft/BCApps/blob/8f7a04cb0db8aa96cb97e055c45c61aead49e280/src/Layers/W1/BaseApp/Inventory/Requisition/ReqWkshMakeOrder.Codeunit.al#L663-L743)
