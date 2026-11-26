---
bc-version: [23..]
domain: copilot
keywords: [promptdialog, prompt-dialog, generate, keep-it, discard, onqueryclosepage, closeaction, temporary-proposal, responsible-ai]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Save PromptDialog proposals only when the user keeps them

## Description

A `PromptDialog` page shows AI-generated content as a proposal. The user reviews it and then chooses **Keep it** (`systemaction(OK)`) or **Discard** (`systemaction(Cancel)`), and may regenerate it several times before deciding. Microsoft's guidance is explicit: do not save an AI-generated proposal to the database until the user chooses to keep it. Writing real records in the `Generate`/`Regenerate` action, or in the procedure it calls, makes Discard and Regenerate leave behind data the user never accepted, such as duplicate lines, half-filled documents, or modified master data.

## Best Practice

Hold the proposal in temporary records (a `SourceTableTemporary` part or temporary record variables) or in page variables while the dialog is open. Persist it in `OnQueryClosePage` when `CloseAction = Action::OK`, or in the caller after `RunModal` returns `Action::OK`, and do it through the normal table triggers and validation. On Discard, do nothing.

See sample: [`save-promptdialog-proposals-only-when-the-user-keeps-them.good.al`](save-promptdialog-proposals-only-when-the-user-keeps-them.good.al).

## Anti Pattern

A `PromptDialog` page whose `Generate` or `Regenerate` system action, or the procedure it calls, inserts or modifies non-temporary records with the generated content. Also an `OnQueryClosePage` that saves regardless of `CloseAction`.

Do not flag writes to temporary proposal buffers, or telemetry and usage logging that records that generation happened without saving the generated business content.

See sample: [`save-promptdialog-proposals-only-when-the-user-keeps-them.bad.al`](save-promptdialog-proposals-only-when-the-user-keeps-them.bad.al).

## References

[Design content mode of prompt dialog page, Add a save and discard action](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/copilot-design-content-mode#add-a-save-and-discard-action) and [The PromptDialog page type](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-page-type-promptdialog).
