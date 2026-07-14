---
bc-version: [all]
domain: privacy
keywords: [privacy-notice, integration, register, onregisterprivacynotices, notice-id]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Register custom integrations with Codeunit Privacy Notice

## Description

The current extension point is `Codeunit "Privacy Notice"`. Extensions can subscribe to its `OnRegisterPrivacyNotices` event and add a dedicated notice ID, integration name, and link to the temporary `Privacy Notice` record. For explicit creation outside the default-registration flow, the same codeunit exposes `CreatePrivacyNotice`. `Codeunit "Privacy Notice Registrations"` contains IDs for built-in integrations and is not the registration API for a custom service.

## Best Practice

Choose a stable ID owned by the extension. Register it through `OnRegisterPrivacyNotices`, or call `PrivacyNotice.CreatePrivacyNotice` during an intentional setup or upgrade path. Use that same ID for consent checks described in `privacy-notice-consent-for-external-data-transfer.md`.

See sample: `register-integration-in-privacy-notice-registrations.good.al`.

## Anti Pattern

Reusing the Exchange or another built-in notice ID for a custom integration, subscribing to `Privacy Notice Registrations`, or calling the nonexistent `CreatePrivacyNoticeForIntegration` method. These shapes attach consent to the wrong service or do not compile.
