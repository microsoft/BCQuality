---
bc-version: [all]
domain: breaking-changes
keywords: [email, codeunit-mail, email-message, email-scenario, email-account, smtp, sending-email]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Send email through the Email module, not Codeunit Mail (397)

> Contributions welcome — open a PR to refine or extend this article.

## Description

Older AL code sends email by calling `Codeunit Mail (397)`. Business Central's current extensibility model is a different, richer object set — `Codeunit Email`, `Codeunit "Email Message"`, `enum "Email Scenario"`, and the `Email Account`/`Email Connector` interface (Microsoft 365, Current User, SMTP, or a custom connector). `Codeunit "Email Message"` is the in-memory object you build the message on; it is not itself the persisted Sent/Outbox/Draft record — that storage is managed separately once the message is queued or sent. New code built on `Codeunit Mail` inherits its SMTP-era, single-connector assumptions and leaves no Sent/Outbox trail behind.

## Best Practice

Build on `Codeunit Email` and `Codeunit "Email Message"`. Route the message through an `Email Scenario` so different document types can use different accounts without the calling code needing to know which account that is, and get a tracked Sent/Outbox/Draft record for free.

See sample: `prefer-email-module.good.al`.

## Anti Pattern

Calling `Codeunit Mail`'s `CreateMessage`. It still compiles and runs, but current `Codeunit Mail`'s own implementation of `CreateMessage` no longer sends anything by itself — it only raises integration events for a legacy subscriber to act on — so building new code on it means depending on whatever compatibility shim happens to still be wired up, with no first-class connector selection and no queryable Sent/Outbox/Draft record. `Send` and `GetErrorDesc` are not current members of `Codeunit Mail` at all; do not reference them.

See sample: `prefer-email-module.bad.al`.
