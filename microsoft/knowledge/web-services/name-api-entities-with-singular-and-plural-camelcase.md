---
bc-version: [all]
domain: web-services
keywords: [api-page, entityname, entitysetname, camelcase, singular-plural, apiversion, naming-convention]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Name API entities with a singular EntityName and a plural EntitySetName, both camelCase

## Description

API v2 entity names follow a strict convention: `EntityName` is the singular noun for one record (`customer`), `EntitySetName` is its plural for the collection (`customers`), and both are camelCase — a lowercase first letter, no spaces or underscores. `APIVersion` follows the `vX.Y` shape (`v1.0`). The platform treats these as contract-shaping rules, not cosmetics: a casing violation raises a compiler warning and a naming violation (using a plural where the singular is expected, or PascalCase where camelCase is expected) is flagged as an error. LLMs frequently default to BC's PascalCase object-naming habit (`Customer`, `SalesOrders`) and carry it into these properties, producing client-facing entity names that read wrong and trip the analyzer. This file is remedial because the singular/plural split is the opposite of how a developer names AL objects.

## Best Practice

Pick the singular camelCase noun for `EntityName` and its plural for `EntitySetName`: `EntityName = 'customer'` with `EntitySetName = 'customers'`; `EntityName = 'salesOrder'` with `EntitySetName = 'salesOrders'`. Keep the first letter lowercase and use camelCase for compound names. Set `APIVersion` to a `vX.Y` literal such as `'v1.0'`. The pair should read naturally in a URL: one `customer`, a set of `customers`.

See sample: `name-api-entities-with-singular-and-plural-camelcase.good.al`.

## Anti Pattern

Swapping and miscasing the pair — `EntityName = 'Customers'` (plural and PascalCase) with `EntitySetName = 'Customer'` (singular). The single-record name now reads as a collection, the collection name reads as one record, and the leading capitals violate camelCase. The detection signal: an `EntityName` that is plural or starts with an uppercase letter, or an `EntitySetName` that is singular.

See sample: `name-api-entities-with-singular-and-plural-camelcase.bad.al`.
