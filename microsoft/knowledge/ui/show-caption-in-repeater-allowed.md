---
bc-version: [all]
domain: ui
keywords: [show-caption, repeater, column-header, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# ShowCaption inside a repeater is harmless

## Description

Fields inside a `repeater()` control are labeled by their **column headers**, not by their own captions. `ShowCaption = false` on a field inside a repeater is harmless and should not be flagged.

This is the explicit behaviour of the Business Central client: a repeater renders as a tabular list whose column headings come from each field's `Caption` (or source-table caption), and individual row cells do not announce a per-cell caption.

## Best Practice

Inside a repeater, you may set `ShowCaption = false` on fields without losing accessibility. The column header still provides the label for every cell in that column. Outside a repeater, the rules in `show-caption-on-editable-fields.md` apply.

See sample: [`show-caption-in-repeater-allowed.good.al`](show-caption-in-repeater-allowed.good.al).
