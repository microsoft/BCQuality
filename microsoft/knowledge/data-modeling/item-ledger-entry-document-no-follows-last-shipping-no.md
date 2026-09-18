---
bc-version: [all]
domain: data-modeling
keywords: [item-ledger-entry, document-no, last-shipping-no, ship-and-invoice, posting, sales-order]
technologies: [al]
countries: [w1]
application-area: [all]
---

# After Ship-and-Invoice posting, Item Ledger Entry carries the shipment document number

## Description

Posting a sales order with both Ship and Invoice in one call creates the Item Ledger Entry during the shipment leg of that combined post, so the entry's `Document No.` is stamped with the value assigned to the shipment — `Sales Header."Last Shipping No."` — not the posted sales invoice number the posting call returns. Code that filters Item Ledger Entry by the invoice number instead finds nothing: `SetRange`/`FindSet` simply return zero rows, with no error to signal the mistake.

## Best Practice

After posting a sales order with Ship and Invoice together, read `SalesHeader."Last Shipping No."` (populated during the post) and filter Item Ledger Entry by that value, not by the invoice number the posting routine returns.

See sample: `item-ledger-entry-document-no-follows-last-shipping-no.good.al`.

## Anti Pattern

Filtering Item Ledger Entry by the posted sales invoice number after a combined Ship-and-Invoice post. The filter compiles and runs without error but matches zero rows, because the entry belongs to the shipment leg of the posting, not the invoice leg.

See sample: `item-ledger-entry-document-no-follows-last-shipping-no.bad.al`.
