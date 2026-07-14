---
bc-version: [all]
domain: privacy
keywords: [privacy-notice, consent, http-client, outgoing-request, external-service, confirmprivacynoticeapproval]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Check the custom Privacy Notice before external data transfer

## Description

Business Central's `Codeunit "Privacy Notice"` creates notices and records per-integration approval. A custom integration needs its own stable notice ID; it must not borrow the Exchange or another built-in service's consent. `ConfirmPrivacyNoticeApproval` shows the notice when needed and returns whether the request is approved. `GetPrivacyNoticeApprovalState` checks an existing notice without showing UI.

## Best Practice

Register the custom notice with `CreatePrivacyNotice` during setup or through `OnRegisterPrivacyNotices`. Before sending data, call `ConfirmPrivacyNoticeApproval(<custom id>)` outside a write transaction, or check `GetPrivacyNoticeApprovalState(<custom id>)` when the flow must not show UI. No path should issue the request without approval.

See sample: `privacy-notice-consent-for-external-data-transfer.good.al`.

## Anti Pattern

A custom integration that posts data without checking its own notice, or that gates the call with a built-in ID such as the Exchange privacy notice ID. Consent for one service does not authorize another.

See sample: `privacy-notice-consent-for-external-data-transfer.bad.al`.
