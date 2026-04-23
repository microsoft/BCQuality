---
bc-version: [all]
domain: privacy
keywords: [page, display, permission, authenticated, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pages displaying data to permitted users are not a privacy concern

## Description

Every page in Business Central displays data to an authenticated user who holds the permissions required to see it. The permission system — table permissions, entitlements, field-level restrictions where configured — is the access-control boundary. Flagging a page for showing customer emails, names, addresses, document numbers, or system audit fields treats display as a leak when it is the product's intended function.

## Best Practice

Privacy review of pages is about data classification on the source table and about consent on outgoing integrations reached through page actions. Displaying business data to a user with permission to view it is correct behaviour, including on API pages that are gated by the same permission model.

## Anti Pattern

Reporting "customer email is shown on the page" or "user ID visible in the list" as privacy findings. The finding does not reflect a privacy regression and redirects the author toward hiding data that the permitted user is entitled to see. The same logic produces noise on Confirm, Message, and Notification that surface business identifiers.
