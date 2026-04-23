---
bc-version: [all]
domain: privacy
keywords: [privacy-notice, consent, gdpr, httpclient, outgoing-request]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Check Privacy Notice consent before outgoing requests with customer data

## Description

Business Central ships a Privacy Notice framework for user consent to third-party integrations. When code sends personal data (emails, names, addresses) to an external service, the concern is not whether the data itself is compliant — the product handles that — but whether the code path has verified the user has agreed to the integration. Missing consent checks on new or modified outgoing paths is the privacy issue to flag; the presence of PII in the payload is not.

## Best Practice

Before an outgoing HttpClient call that carries customer data, verify consent via `Codeunit "Privacy Notice".GetPrivacyNoticeApprovalState()` for the integration's registered notice id. The check may live upstream (page OnOpenPage, wizard step) as long as every path that reaches the external call passes through it. Register new integrations via `Codeunit "Privacy Notice Registrations"`.

See sample: `require-privacy-notice-consent-before-outgoing-requests.good.al`.

## Anti Pattern

Adding or modifying an outgoing integration and sending customer data without any `Privacy Notice` check in the reachable code path. Removing an existing consent check from an integration that still sends data externally falls in the same category.

See sample: `require-privacy-notice-consent-before-outgoing-requests.bad.al`.
