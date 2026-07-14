---
bc-version: [17..]
domain: web-services
keywords: [api-page, page-part, subpagelink, systemid, multiplicity, deep-insert, navigation-property]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Link API parts on SystemId and choose the correct multiplicity

## Description

An API page part creates an OData navigation property and, for a 1:N relationship, enables deep insert of child entities. When a custom parent API is keyed by its immutable `SystemId`, its child should carry a related GUID foreign key so the navigation constraint uses that same stable external identity. Omitted `Multiplicity` validly defaults to 1:N collection metadata; set `ZeroOrOne` explicitly only when the part is intended to expose a singleton.

## Best Practice

Define the child foreign key as `Guid` with a `TableRelation` to the parent table's `SystemId`, then use `SubPageLink = "<Parent Id>" = Field(SystemId)` on the parent API page. For a child collection and deep insert, either use the documented default or declare `Multiplicity = Many`; for singleton metadata, declare `Multiplicity = ZeroOrOne`.

See sample: `link-api-parts-on-systemid-and-set-multiplicity.good.al`.

## Anti Pattern

On a parent API with `ODataKeyFields = SystemId`, linking a child business field such as `"Order No."` to the parent's `"No."` creates a second identity scheme for navigation instead of using the contract's stable GUID. A separate defect is an explicit multiplicity that contradicts the intended shape, such as `ZeroOrOne` on an order-lines collection or `Many` on a singleton. Omission alone is valid for the default 1:N collection.

See sample: `link-api-parts-on-systemid-and-set-multiplicity.bad.al`.

## Source

[Developing a custom API](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-develop-custom-api) and [Multiplicity property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-multiplicity-property). `Multiplicity` is available from runtime 6.3, shipped with Business Central 17.3; BC17 consumers therefore need update 17.3 or later.
