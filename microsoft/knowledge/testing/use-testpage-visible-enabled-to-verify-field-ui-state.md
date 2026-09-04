---
bc-version: [all]
domain: testing
keywords: [testpage, visible, enabled, ui-state, headless-test, field-verification]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Verify field visibility and editability with TestPage.Visible()/.Enabled()

## Description

A UI test codeunit does not need to inspect table or page properties indirectly to confirm a field is shown or editable under given conditions. The `TestPage` object exposes a `Visible()` and an `Enabled()` function on each field, reflecting the page's actual rendered state, callable directly from a `[Test]` procedure after `OpenView()`.

## Best Practice

Open the `TestPage`, navigate to the relevant record if needed, then assert against `TestPageField.Visible()` and `TestPageField.Enabled()` to verify the field's UI state, rather than checking an unrelated table/page property or skipping the check.

See sample: `use-testpage-visible-enabled-to-verify-field-ui-state.good.al`.

## Anti Pattern

A test that opens the `TestPage` but never asserts against `Visible()`/`Enabled()` on the field in question — confirming only that the page opens, not that the field behaves as expected.

See sample: `use-testpage-visible-enabled-to-verify-field-ui-state.bad.al`.
