---
bc-version: [all]
domain: ui
keywords: [showmandatory, notblank, mandatory-field, red-asterisk, delayedinsert, testfield, page-field]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Mark code-required page fields with ShowMandatory

> Contributions welcome — open a PR to refine or extend this article.

## Description

`ShowMandatory` draws the red asterisk on a page field and, per the platform documentation, enforces no validation. The reverse is not reliable: code that enforces a value — `TestField` in `OnInsert`/`OnModify`, a `NotBlank` table field, a mandatory setup value — does not guarantee that the page field renders as mandatory. Because the two halves are independent, it is easy to ship a field that the code requires but the UI presents as optional. Microsoft documents that `NotBlank` can mark primary-key fields, but current client behavior does not do so consistently; on non-primary-key fields, a value that was never entered is not validated at all. `ShowMandatory` also overrides any marking `NotBlank` would contribute, so set it explicitly when the page must communicate a requirement. The gap is widest on a list page with `DelayedInsert = true`, where the enforcing error surfaces only when the user leaves the row — after the rest of the line is typed, with nothing having indicated which field was missing.

## Best Practice

Set `ShowMandatory = true` on every visible, editable page field whose value the user must supply before the record can be committed or an action can complete, and leave the enforcement in place: the property is presentation, `TestField`/`Error` is the guarantee, and the two belong together in the same change. When the requirement is conditional, bind `ShowMandatory` to a Boolean variable or field that mirrors the condition the enforcement checks — the base application drives `Vendor Invoice No.` on the Purchase Invoice page from an `Ext. Doc. No. Mandatory` setup flag this way. Two expression limits are worth knowing: the property cannot call an AL method, so compute the value into a variable first, and a numeric field that has a default value counts as filled, so it never shows the asterisk. See sample: `showmandatory-on-code-required-page-fields.good.al`.

## Anti Pattern

A required field with no mandatory marker: the table's `OnInsert` or the page's `OnInsertRecord` calls `TestField` on a field, or `NotBlank` is expected to force entry, while the page field bound to it carries no `ShowMandatory`. On a `DelayedInsert = true` list page the user fills the row, leaves it, and gets an error naming a field that never looked different from the optional ones. Reviewer signal: code on the relevant commit or action path requires the user to supply a field, the corresponding page control is visible and editable, and its `ShowMandatory` property is missing or does not mirror the same condition. A `TestField` or `Error` elsewhere in `OnValidate` or `OnModify` is not sufficient evidence: the field may be populated by code, non-editable, or required only for another path. Setting `ShowMandatory = false` on a field that is unconditionally required on the current path is the same defect stated explicitly, and per the documentation it also overrides any marking `NotBlank` would otherwise contribute. See sample: `showmandatory-on-code-required-page-fields.bad.al`.

## See also

`ShowMandatory` property — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-showmandatory-property

`NotBlank` property — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-notblank-property

Review finding this article generalizes — https://github.com/microsoft/BCApps/pull/9315#discussion_r3568817946
