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

Older AL code sends email by calling `Codeunit Mail (397)`. Business Central's current extensibility model is a different, richer object set — `Codeunit Email`, table `Email Message`, `enum "Email Scenario"`, and the `Email Account`/`Email Connector` interface (Microsoft 365, Current User, SMTP, or a custom connector). New code built on `Codeunit Mail` inherits its SMTP-era, single-connector assumptions and leaves no Sent/Outbox trail behind.

## Best Practice

Build on `Codeunit Email` and table `Email Message`. Route the message through an `Email Scenario` so different document types can use different accounts without the calling code needing to know which account that is, and get a tracked Sent/Outbox/Draft record for free.

See sample: `prefer-email-module.good.al`.

## Anti Pattern

Calling `Codeunit Mail`'s `CreateMessage`/`Send`/`GetErrorDesc`. It still runs, but it is hard-coupled to whatever SMTP setup exists, and leaves no queryable record of what was sent.

See sample: `prefer-email-module.bad.al`.
