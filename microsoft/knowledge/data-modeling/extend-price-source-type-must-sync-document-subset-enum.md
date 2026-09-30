---
bc-version: [all]
domain: data-modeling
keywords: [price-calculation, price-source, price-source-type, enumextension, pricing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Extend Price Source Type and its matching document subset enum together, with the same ID

## Description

`enum 7003 "Price Source Type"` (`implements "Price Source", "Price Source
Group"`) is the base list of who a price can apply to — Customer, Vendor,
Customer Price Group, Campaign, and so on. It is not, by itself, what
drives the "Applies-to Type" field on an actual sales, purchase, or job
price list. Each document area has its own subset enum —
`enum 7006 "Sales Price Source Type"`, the equivalent purchase and job
enums — and these are what the price list pages actually expose. Every
value the two enums share today uses the identical numeric ID: `All
Customers`/`Customer`/`Customer Price Group`/`Customer Disc.
Group`/`Campaign`/`Contact` are 10/11/12/13/50/51 in both `Price Source
Type` and `Sales Price Source Type`.

Adding a new value to `Price Source Type` alone does nothing for a sales
price list: the base enum and the document subset enum are two separate
extensible enums, linked only by convention, not by any platform
mechanism that keeps their IDs in sync. Give the new value a different ID
in each enum, or extend only the base enum, and the source is real and
selectable in some contexts (the base enum is used elsewhere, such as
the generic `Price Source` table) but absent from the specific document
price list a developer actually tested against.

## Best Practice

When a new price source should be usable in a sales, purchase, or job
price list, extend `Price Source Type` and the matching document subset
enum (`Sales Price Source Type`, `Purchase Price Source Type`, `Job Price
Source Type`) together, using the identical numeric ID in both.

See sample: [`extend-price-source-type-must-sync-document-subset-enum.good.al`](extend-price-source-type-must-sync-document-subset-enum.good.al).

## Anti Pattern

Extending `Price Source Type` with a new value intended for sales price
lists, without extending `Sales Price Source Type` with a value of the
same ID — or giving it a different ID. Either way, the new source is
absent from the "Applies-to Type" options on an actual sales price list,
with no error anywhere: the base enum extension compiles and installs
cleanly on its own.

See sample: [`extend-price-source-type-must-sync-document-subset-enum.bad.al`](extend-price-source-type-must-sync-document-subset-enum.bad.al).

## Source

BCApps (`src/Layers/W1/BaseApp/`): `Pricing/Source/PriceSourceType.Enum.al`
(`enum 7003 "Price Source Type"`, values `10/11/12/13/50/51` for `All
Customers`/`Customer`/`Customer Price Group`/`Customer Disc.
Group`/`Campaign`/`Contact`) and `Sales/Pricing/SalesPriceSourceType.Enum.al`
(`enum 7006 "Sales Price Source Type"`, the same six values at the same
six IDs). Microsoft Learn, "Extending Price Calculations": "The Price
Source Type enum implements the Applies-to Type field in the header of
the price list. Additionally, the Sales Price Source Type, Purchase Price
Source Type, and Job Price Source Type are subsets of the Price Source
Type enum... For compatibility, the new value must have the same ID in
both enums."
(https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-extending-best-price-calculations)
