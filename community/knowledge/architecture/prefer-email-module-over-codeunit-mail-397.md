---
bc-version: [all]
domain: architecture
keywords: [email, codeunit-mail, email-message, email-scenario, email-account, smtp, sending-email]
technologies: [al]
countries: [w1]
application-area: [all]
---
# New email-sending code should use the Email module, not Codeunit Mail (397)

> Contributions welcome — open a PR to refine or extend this article.

## Description
Business Central's current extensibility model for sending email is `Codeunit Email`, table `Email Message`, `enum Email Scenario`, and the `Email Account`/`Email Connector` interface — documented under "Extend Email Capabilities" and "Set up email." Older AL code, and some LLM training data, still reaches for the earlier `Codeunit Mail (397)` (`CreateMessage`/`Send`/`GetErrorDesc`), which is hard-coupled to one SMTP-style connector and leaves no record behind once a message is sent. New AL development that sends email should build on the Email module, not `Codeunit Mail (397)`.

## Best Practice
Create the message through `Codeunit "Email Message"` and send it through `Codeunit Email`, routed by an `Email Scenario` rather than a hard-coded account. This keeps the calling code independent of which connector (Microsoft 365, Current User, SMTP, or a partner connector) the customer has configured, gives every message a tracked Sent/Outbox/Draft status, and lets different document types route through different accounts without the caller needing to know which one.

## Anti Pattern
Calling `Codeunit Mail`'s `CreateMessage`/`Send`/`GetErrorDesc` in new code still compiles and runs, but it inherits SMTP-era assumptions, leaves no Sent/Outbox trail, and hard-codes the connector choice into the calling code. A reviewer can spot it by any new reference to `Codeunit Mail (397)` outside of already-existing legacy call sites.
