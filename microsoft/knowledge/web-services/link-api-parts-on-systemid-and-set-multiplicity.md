---
bc-version: [18..]
domain: web-services
keywords: [api-page, page-part, subpagelink, systemid, multiplicity, deep-insert, navigation-property]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Link API parts on SystemId and declare their multiplicity

## Description

An API page part creates an OData navigation property and, for `Multiplicity = Many`, enables deep insert of child entities. When a custom parent API is keyed by its immutable `SystemId`, its child should carry a related GUID foreign key so the navigation constraint uses that same stable external identity. `Multiplicity` also controls whether metadata exposes an object (`ZeroOrOne`) or a collection (`Many`), so declare it deliberately instead of relying on the default 1:N relationship.

## Best Practice

Define the child foreign key as `Guid` with a `TableRelation` to the parent table's `SystemId`, then use `SubPageLink = "<Parent Id>" = Field(SystemId)` on the parent API page. Set `Multiplicity = Many` for child collections and deep insert, or `Multiplicity = ZeroOrOne` for a singleton navigation property.

See sample: `link-api-parts-on-systemid-and-set-multiplicity.good.al`.

## Anti Pattern

On a parent API with `ODataKeyFields = SystemId`, linking a child business field such as `"Order No."` to the parent's `"No."`, or omitting `Multiplicity` because the current default happens to produce a collection. The first creates a second identity scheme for navigation instead of using the contract's stable GUID; the second hides whether the contract intentionally exposes a singleton or collection.

See sample: `link-api-parts-on-systemid-and-set-multiplicity.bad.al`.

## Source

[Developing a custom API](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-develop-custom-api) and [Multiplicity property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-multiplicity-property).
