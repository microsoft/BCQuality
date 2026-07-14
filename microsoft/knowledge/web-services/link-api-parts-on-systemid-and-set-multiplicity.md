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

`Multiplicity` is available from runtime 6.3 (Business Central 17.3) and defaults an API page part to a 1:N collection. The multiplicity-specific guidance therefore does not apply to BC 17.0 through 17.2. An API page part creates an OData navigation property and, for collection multiplicity, enables deep insert of child entities. When a custom parent API is keyed by its immutable `SystemId`, its child should carry a related GUID foreign key so the navigation constraint uses that same stable external identity. `Multiplicity` controls whether metadata exposes an object (`ZeroOrOne`) or a collection (`Many`).

## Best Practice

Define the child foreign key as `Guid` with a `TableRelation` to the parent table's `SystemId`, then use `SubPageLink = "<Parent Id>" = Field(SystemId)` on the parent API page. A child collection may omit `Multiplicity` and rely on the default 1:N relationship, or declare `Multiplicity = Many` explicitly. Set `Multiplicity = ZeroOrOne` when the intended navigation metadata is a singleton.

See sample: `link-api-parts-on-systemid-and-set-multiplicity.good.al`.

## Anti Pattern

On a parent API with `ODataKeyFields = SystemId`, linking a child business field such as `"Order No."` to the parent's `"No."` creates a second identity scheme for navigation instead of using the contract's stable GUID. A separate defect is an explicit `Multiplicity` that conflicts with the intended shape, such as `ZeroOrOne` on an order-lines collection or `Many` on a singleton. Do not treat omission alone as a defect: it is valid for a collection because the default is 1:N, while an intended singleton must explicitly use `Multiplicity = ZeroOrOne`.

See sample: `link-api-parts-on-systemid-and-set-multiplicity.bad.al`.

## Source

[Developing a custom API](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-develop-custom-api) and [Multiplicity property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-multiplicity-property).
