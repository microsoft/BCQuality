---
bc-version: [23..]
domain: copilot
keywords: [prompt-injection, metaprompt, system-message, setprimarysystemmessage, addsystemmessage, addusermessage, aoai-chat-messages, user-input]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep user input and record text out of the system message

## Description

`AOAI Chat Messages` separates roles: the system message (`SetPrimarySystemMessage`, `AddSystemMessage`) holds the metaprompt that defines the model's task, output format, and guard rails; user messages (`AddUserMessage`) carry what the user typed and the business data to work on. Models give system instructions more weight than user content. When an extension concatenates free text from the user, or from record fields that users or external parties can edit (descriptions, comments, imported e-mails, vendor names), into the system message, that text can override the metaprompt: change the output format the AL code parses, remove guard rails, or redirect the task. This is prompt injection, and placing the text in the system role makes it more effective.

## Best Practice

Keep the system message static and owned by the extension: the task, the output contract, and the rules. Pass the user's prompt and any record data as user messages, clearly delimited (for example, as a JSON object or between labeled markers) and described in the metaprompt as data, not instructions. Still validate the model's output before using it, because separating roles reduces injection risk without removing it.

See sample: [`keep-user-input-out-of-the-system-message.good.al`](keep-user-input-out-of-the-system-message.good.al).

## Anti Pattern

A call to `SetPrimarySystemMessage` or `AddSystemMessage` whose text is built with `+`, `StrSubstNo`, or a `TextBuilder` from a PromptDialog input field, a procedure parameter that carries user text, or a user-editable record field. Values the extension controls, such as a language code, today's date, or an option caption, are not this defect.

See sample: [`keep-user-input-out-of-the-system-message.bad.al`](keep-user-input-out-of-the-system-message.bad.al).

## References

[Build the Copilot capability in AL](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/ai-build-capability-in-al) (AOAI Chat Roles: `User` is end-user input, `System` guides the model through the metaprompt; the metaprompt sets the guard rails) and [System message framework and template recommendations](https://learn.microsoft.com/en-us/azure/ai-services/openai/concepts/system-message). The injection risk of mixing roles is general LLM security guidance applied to these BC APIs.
