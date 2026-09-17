---
bc-version: [all]
domain: ui
keywords: [show-caption, non-editable, content, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# ShowCaption = false on non-editable fields

## Description

When a field is explicitly non-editable (`Editable = false`), it serves as content rather than as a form field. In that case, `ShowCaption = false` is acceptable: there is no input control whose label could be lost. The combination signals to a reviewer (and to the platform) that the field displays a value standalone — for example a status message or a description that is meaningful on its own.

This exception does **not** extend to dynamically editable fields. A field with `Editable = SomeBooleanExpression` may be editable at runtime and must keep its caption.

## Best Practice

If you want to hide a field's caption, pair `ShowCaption = false` with a literal `Editable = false`. Use this pattern only for content fields that do not act as labels for other fields in the same layout container.

See sample: [`show-caption-false-allowed-on-non-editable-fields.good.al`](show-caption-false-allowed-on-non-editable-fields.good.al).
