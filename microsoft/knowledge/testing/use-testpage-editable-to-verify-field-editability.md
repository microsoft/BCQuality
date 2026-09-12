---
bc-version: [all]
domain: testing
keywords: [testpage, editable, openedit, ui-state, field-verification]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Verify field editability with TestPage.Editable(), opened in edit mode

## Description

Whether a field can actually be changed is a distinct state from whether it is shown or enabled — `Editable()` and `Enabled()` are separate `TestField` functions. Verifying editability also requires opening the `TestPage` with `OpenEdit()`, not `OpenView()`: `OpenView()` opens the page in view mode, so it does not exercise the field's own conditional editability logic the way an actual edit-mode session does.

## Best Practice

Open the `TestPage` with `OpenEdit()`, navigate to the relevant record, then assert against `TestPageField.Editable()` to verify whether the field can be changed under the given precondition.

See sample: `use-testpage-editable-to-verify-field-editability.good.al`.

## Anti Pattern

Asserting `Enabled()` (or checking nothing at all) when the actual claim is about editability, or opening the page with `OpenView()` when the field's editability depends on business logic that only applies in edit mode.

See sample: `use-testpage-editable-to-verify-field-editability.bad.al`.
