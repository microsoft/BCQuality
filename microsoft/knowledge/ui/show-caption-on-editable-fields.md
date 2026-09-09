---
bc-version: [all]
domain: ui
keywords: [show-caption, editable, accessibility, label, instructional-text]
technologies: [al]
countries: [w1]
application-area: [all]
---

# ShowCaption on editable fields

## Description

`ShowCaption` must remain true (the default) on editable fields unless the field matches one of the officially supported "magic patterns". Fields are editable by default. Setting `ShowCaption = false` on an editable field is almost always an accessibility bug: without a visible caption, screen reader users lose the label that identifies the field, and sighted users lose a visual cue.

A field whose `Editable` property is a Boolean expression (e.g. `Editable = IsEditable`) is dynamically editable and must be treated as a form field — `ShowCaption = false` on such a field is also a violation.

## Best Practice

Leave `ShowCaption` at its default on editable fields. If a caption would be visually redundant, rely on one of the documented magic patterns (group-labeled first child, repeater column, PromptDialog prompt input) rather than removing the caption.

See sample: [`show-caption-on-editable-fields.good.al`](show-caption-on-editable-fields.good.al).

## Anti Pattern

The `InstructionalText` property on a field renders as HTML placeholder text and is **not** a substitute for a caption — it disappears once the user types and is not reliably announced by screen readers.

See sample: [`show-caption-on-editable-fields.bad.al`](show-caption-on-editable-fields.bad.al).
