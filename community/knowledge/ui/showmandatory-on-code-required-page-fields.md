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

`ShowMandatory` draws the red asterisk on a page field and, per the platform documentation, enforces no validation. The reverse holds too: code that enforces a value — `TestField` in `OnInsert`/`OnModify`, a `NotBlank` table field, a mandatory setup value — changes nothing about how the field renders. Because the two halves are independent, it is easy to ship a field that the code requires but the UI presents as optional. `NotBlank` does not close the gap: the documentation confines any marking it may contribute to primary-key fields, states that on any other field a value which was never entered is not validated at all, and notes that `ShowMandatory` overrides whatever marking `NotBlank` would contribute — so `ShowMandatory` is the only property to rely on for the asterisk. The gap is widest on a list page with `DelayedInsert = true`, where the enforcing error surfaces only when the user leaves the row — after the rest of the line is typed, with nothing having indicated which field was missing.

## Best Practice

Set `ShowMandatory = true` on every page field whose value the code requires before the record can be committed, and leave the enforcement in place: the property is presentation, `TestField`/`Error` is the guarantee, and the two belong together in the same change. When the requirement is conditional, bind `ShowMandatory` to a Boolean variable or field that mirrors the condition the enforcement checks — the base application drives `Vendor Invoice No.` on the Purchase Invoice page from an `Ext. Doc. No. Mandatory` setup flag this way. Two expression limits are worth knowing: the property cannot call an AL method, so compute the value into a variable first, and a numeric field that has a default value counts as filled, so it never shows the asterisk. See sample: `showmandatory-on-code-required-page-fields.good.al`.

## Anti Pattern

A required field with no mandatory marker: the table's `OnInsert` or the page's `OnInsertRecord` calls `TestField` on a field, or `NotBlank` on a non-primary-key field is expected to force entry, while the page field bound to it carries no `ShowMandatory`. On a `DelayedInsert = true` list page the user fills the row, leaves it, and gets an error naming a field that never looked different from the optional ones. Reviewer signal: a `TestField` or `Error` naming a field in `OnInsert`, `OnInsertRecord`, `OnModify`, or `OnValidate`, or `NotBlank = true` on a table field, with no `ShowMandatory` on the corresponding page field — exactly the review finding on the `Job Assigned Resources` page linked below. Setting `ShowMandatory = false` on a required field is the same defect stated explicitly, and per the documentation it also overrides any marking `NotBlank` would otherwise contribute. See sample: `showmandatory-on-code-required-page-fields.bad.al`.

## See also

`ShowMandatory` property — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-showmandatory-property

`NotBlank` property — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-notblank-property

Review finding this article generalizes — https://github.com/microsoft/BCApps/pull/9315#discussion_r3568817946
