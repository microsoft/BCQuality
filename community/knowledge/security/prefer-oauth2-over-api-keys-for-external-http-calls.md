---
bc-version: [26..28]
domain: security
keywords: [oauth2, api-key, authentication, httpclient, token-refresh]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer OAuth2 over API keys for external HTTP calls

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

External HTTP integrations from AL can authenticate using OAuth 2.0 (client-credentials for service-to-service, authorization-code for user-delegated), API keys, basic authentication, or credentials in URLs. The mechanisms differ substantially in the blast radius of a leaked secret and in how cleanly tokens can be rotated. OAuth-issued tokens expire on their own schedule and rotate cleanly; API keys and basic-auth passwords typically have to be rotated manually and usually live unencrypted in a configuration table. When the partner supports OAuth, the difference is a material security improvement, not a stylistic preference.

## Best Practice

When the partner supports OAuth, use the platform `OAuth2` codeunit (`AcquireTokenWithClientCredentials` for service-to-service, `AcquireAuthorizationCodeTokenFromCache` for user-delegated flows) rather than hand-rolled token acquisition. Carry tokens and client secrets as `SecretText`, persist them only in IsolatedStorage, and refresh tokens proactively — on a buffer before the documented expiry — so routine calls never block on a token refresh.

See sample: `prefer-oauth2-over-api-keys-for-external-http-calls.good.al`.

## Anti Pattern

Accepting an API-key or basic-auth integration because it is the first option documented, even when the partner supports OAuth. The shared secret usually ends up in a setup-table `Text` field, rotation becomes a manual operation that rarely happens, and a single disclosure exposes every tenant using the extension.

See sample: `prefer-oauth2-over-api-keys-for-external-http-calls.bad.al`.
