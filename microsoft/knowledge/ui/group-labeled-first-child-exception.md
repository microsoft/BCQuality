---
bc-version: [all]
domain: ui
keywords: [show-caption, group, first-child, multiline, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Group-labeled first child exception

## Description

`ShowCaption = false` is acceptable on an editable field only when **all** of the following conditions are met:

1. The control is the **first visible field** in its parent group.
2. The field has `ShowCaption = false`.
3. The parent group has a visible caption: `ShowCaption` is true (the default) **and** the group has a non-empty `Caption` value.

When these three conditions hold, the group caption becomes the accessible label for the field. This works regardless of whether the field is multiline. The presence of `InstructionalText` on the field is irrelevant to this check.

## Best Practice

Do not second-guess this exception. If the three conditions are met, the pattern is acceptable — even if the group caption seems generic (e.g. "General Information") or does not exactly match the field name.

See sample: [`group-labeled-first-child-exception.good.al`](group-labeled-first-child-exception.good.al).

## Anti Pattern

If the parent group has `ShowCaption = false` or no `Caption`, the first-child exception does not apply: the field has no accessible label anywhere.

See sample: [`group-labeled-first-child-exception.bad.al`](group-labeled-first-child-exception.bad.al).
