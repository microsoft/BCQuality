---
bc-version: [all]
domain: web-services
keywords: [api-query, querytype-api, api-page, read-only, webhook, aggregate, join, custom-api]
technologies: [al]
countries: [w1]
application-area: [all]
---

# An API query is read-only and does not support webhooks

## Description

A custom API can be exposed by a page with `PageType = API` or by a query with `QueryType = API`, and the two are not interchangeable. An API query generates a read-only endpoint: its data can only be viewed. It can combine and aggregate data from several tables in one request, which a single API page cannot, because an API page has one source table and reaches related tables only through nested page parts. An API page supports read and write operations and webhooks; an API query supports neither writes nor webhooks. Neither object type can be extended, and an API query cannot be used to display data in the user interface.

Choosing the wrong one is a design defect that compiles: a query-based endpoint that a client later needs to write to, or subscribe to, has to be replaced by a new API page with a different shape.

## Best Practice

Use an API query for a read-only joined or aggregated dataset, such as totals per customer across ledger tables. Use an API page when the consumer must create, modify, or delete records, or needs change notifications. Decide from the consumer's operations, not from which object is quicker to write.

Because API objects cannot be extended, another publisher's API query that lacks a column is addressed by publishing a new API object, not by an extension of it.

See sample: [`api-query-is-read-only-and-has-no-webhooks.good.al`](api-query-is-read-only-and-has-no-webhooks.good.al).

## Anti Pattern

Reporting an API query for missing insert, modify, or delete handling, or for not disabling write operations: there are none to handle or disable. The page-oriented guidance in [`disable-write-operations-on-read-only-api-pages.md`](disable-write-operations-on-read-only-api-pages.md) does not apply to queries.

The opposite defect is a read-only reporting endpoint assembled as an API page with nested parts and client-side joins when one API query would return the aggregated rows, or an API query chosen for an entity that integration partners are expected to update or to follow through webhooks; see [`webhook-eligibility-and-validationtoken-renewal.md`](webhook-eligibility-and-validationtoken-renewal.md).

See sample: [`api-query-is-read-only-and-has-no-webhooks.bad.al`](api-query-is-read-only-and-has-no-webhooks.bad.al).

## References

[Develop custom APIs with pages and queries](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-api) and [API query type](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-api-querytype).
