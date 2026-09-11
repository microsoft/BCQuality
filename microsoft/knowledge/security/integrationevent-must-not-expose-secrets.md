---
bc-version: [all]
domain: security
keywords: [integrationevent, eventsubscriber, secrets, credentials, publisher]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not pass credentials or secrets through IntegrationEvent parameters

## Description

`[IntegrationEvent]` publishes a hook that any extension can subscribe to. Every parameter of the event signature is visible to every subscriber — including `var` parameters, which subscribers can both read and modify. A publisher that includes an API key, password, bearer token, or other secret in the event signature hands that secret to every subscriber on the tenant, including subscribers in extensions the publisher has no relationship with. There is no permission or partner-only filter that limits who may subscribe.

## Best Practice

Restrict event payloads to the non-sensitive context a subscriber legitimately needs: the business record being processed (a `Customer`), the operation being performed, an `IsHandled` flag that lets a subscriber skip the default behaviour, and a mutable payload object whose contents the publisher controls. Authentication is handled by the publisher before or after the event, never inside the parameters. See sample: [`integrationevent-must-not-expose-secrets.good.al`](integrationevent-must-not-expose-secrets.good.al).

## Anti Pattern

`[IntegrationEvent(false, false)] procedure OnBeforeSendRequest(var ApiKey: Text; var Password: Text; var RequestUrl: Text)` — any extension on the tenant can subscribe, read `ApiKey` and `Password`, and persist them elsewhere. Reviewers should flag any event parameter whose name or type suggests a secret (`ApiKey`, `Token`, `Password`, `Secret`, `Credential`, `SecretText` — even `SecretText` should not flow through an event surface). See sample: [`integrationevent-must-not-expose-secrets.bad.al`](integrationevent-must-not-expose-secrets.bad.al).
