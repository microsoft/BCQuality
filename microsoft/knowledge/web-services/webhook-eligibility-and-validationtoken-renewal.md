---
bc-version: [all]
domain: web-services
keywords: [webhook, subscription, validationtoken, expirationdatetime, webhook-supported-resources, api-page, sourcetabletemporary, querytype]
technologies: [al, javascript]
countries: [w1]
application-area: [all]
---

# Verify webhook eligibility and complete every validationToken handshake

## Description

Business Central can subscribe only to eligible API pages, not every endpoint that can be read through an API. Webhooks exclude API queries, temporary API pages, pages with composite OData keys, pages over system tables, and pages over Job Queue Entry (table 472); the environment's `webhookSupportedResources` endpoint is authoritative. Creating and renewing a subscription both call the `notificationUrl` with `validationToken`, and both fail unless the subscriber returns that token in the response body with `200 OK`.

## Best Practice

Before creating a subscription, confirm the resource appears in `webhookSupportedResources` and that a custom endpoint is an API page with a single stable key over an eligible persistent table. Use one validation path that echoes `validationToken` for both create (`POST`) and renew (`PATCH`) handshakes. Track `expirationDateTime` and renew before expiry: online subscriptions expire after three days, while on-premises lifetime defaults to three days and can be changed with `ApiSubscriptionExpiration`.

See samples: `webhook-eligibility-and-validationtoken-renewal.good.al` and `webhook-eligibility-and-validationtoken-renewal.good.js`.

## Anti Pattern

Attempting to subscribe to an API query, temporary/composite/system-table/Job Queue Entry API page, or assuming a successful create handshake makes renewal automatic. Composite includes an explicit multi-field `ODataKeyFields` and a missing `ODataKeyFields` when the source table's primary key has multiple fields. A renewal issues the same validation challenge; a notification handler that ignores the query-string token cannot create or renew the subscription.

See samples: `webhook-eligibility-and-validationtoken-renewal.bad.al` and `webhook-eligibility-and-validationtoken-renewal.bad.js`.

## Source

[Working with webhooks](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/api-reference/v2.0/dynamics-subscriptions) and [Update subscriptions](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/api-reference/v2.0/api/dynamics_subscriptions_update).
