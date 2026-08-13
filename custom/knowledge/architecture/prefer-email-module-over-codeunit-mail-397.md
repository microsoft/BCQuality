---
bc-version: [all]
domain: architecture
keywords: [email, codeunit-mail, email-message, email-scenario, email-account, smtp, sending-email]
technologies: [al]
countries: [w1]
application-area: [all]
---

# New email-sending code should use the Email module, not Codeunit Mail (397)

## Description

Older AL code sends email by calling `Codeunit Mail (397)`:
`CreateMessage`, `Send`, `GetErrorDesc`. Business Central's current
extensibility model for email is a different, richer object set —
`Codeunit "Email"`, table `"Email Message"`, `enum "Email Scenario"`, and
the `"Email Account"`/`"Email Connector"` interface (Microsoft 365,
Current User, SMTP, or a custom connector) — documented under "Extend
Email Capabilities" and "Set up email." New AL development that sends
email should build on this module, not `Codeunit Mail (397)`.

The concrete reasons to prefer the Email module: it isn't hard-coupled to
one connector (SMTP setup) the way `Codeunit Mail` historically was — the
same code works whichever connector (Microsoft 365, Current User, SMTP,
or a partner connector) the customer has configured; every message
becomes a tracked `Email Message` record with Sent/Outbox/Draft status
instead of a fire-and-forget call with no record left behind; and
`Email Scenario` lets different document types route through different
accounts without the calling code needing to know which account that is.

## Best Practice

```al
var
    Email: Codeunit Email;
    EmailMessage: Codeunit "Email Message";
begin
    EmailMessage.Create(ToAddress, Subject, Body, true);
    Email.Send(EmailMessage, Enum::"Email Scenario"::Default);
end;
```

## Anti Pattern

```al
var
    Mail: Codeunit Mail;
    MailSent: Boolean;
begin
    Mail.CreateMessage(FromName, ToAddress, CCAddress, Subject, Body, true);
    MailSent := Mail.Send();
    if not MailSent then
        Message(Mail.GetErrorDesc());
end;
```

`Codeunit Mail` still runs, but new code built on it inherits its
SMTP-era assumptions and leaves no Sent/Outbox trail — a maintenance
liability compared to building on the Email module from the start.

## Source

Microsoft Learn, "Extend Email Capabilities" and "Set up email"
(fetched 2026-08-13): the current documented email extensibility surface
is entirely `Email`/`Email Message`/`Email Scenario`/`Email Account`/
`Email Connector`, with no reference to `Codeunit Mail (397)` anywhere in
that guidance. Cross-checked against CURABIS Academy course "The
Developers Guide through AL" (rev. July 2022), Chapter 9: Interfaces,
"E-mail Confirmation" (p. 294–299), which used `Codeunit Mail (397)` as
its example — accurate for its time, superseded since.
