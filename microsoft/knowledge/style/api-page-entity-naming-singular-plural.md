---
bc-version: [all]
domain: style
keywords: [api-page, entityname, entitysetname, singular, plural]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `EntityName` is singular; `EntitySetName` is plural

## Description

`EntityName` and `EntitySetName` on an API page are the two halves of the OData naming contract. `EntityName` names a single record — `'customer'`, `'salesOrder'`, `'item'`. `EntitySetName` names the collection — `'customers'`, `'salesOrders'`, `'items'`. Swapping them — `EntityName = 'customers'`, `EntitySetName = 'customer'` — produces URLs that lie to consumers: `GET /customers` returns one row, `GET /customers('id')` returns a collection. The OData conventions consumers rely on for client-side code generation depend on the singular/plural pairing being correct.

## Best Practice

Pick the singular noun for `EntityName` and its grammatical plural for `EntitySetName`, both in camelCase. For compound nouns, only the trailing noun is pluralized: `EntityName = 'salesOrder'`, `EntitySetName = 'salesOrders'`. For nouns whose plural is irregular, use the natural English form — `EntitySetName = 'people'` for `EntityName = 'person'`.

See sample: [`api-page-entity-naming-singular-plural.good.al`](api-page-entity-naming-singular-plural.good.al).

## Anti Pattern

`EntityName = 'customers'`, `EntitySetName = 'customer'` — singular and plural swapped. Equally wrong is reusing the same form for both — `EntityName = 'customer'`, `EntitySetName = 'customer'` — which breaks OData metadata parsers and client codegen.

See sample: [`api-page-entity-naming-singular-plural.bad.al`](api-page-entity-naming-singular-plural.bad.al).
