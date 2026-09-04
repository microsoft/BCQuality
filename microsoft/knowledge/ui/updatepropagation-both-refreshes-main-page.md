---
bc-version: [all]
domain: ui
keywords: [updatepropagation, page-part, subpage, main-page, refresh, flowfield, document-lines]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use `UpdatePropagation = Both` when line edits must refresh the main page

## Description

A page part does not automatically refresh its parent page when the subpage changes. `UpdatePropagation = Subpage` updates only the part; `Both` also refreshes the main page. Without `Both`, header totals, FlowFields, and FactBoxes that depend on edited lines can remain stale until another user action refreshes the page.

## Best Practice

Set `UpdatePropagation = Both` on a part when edits in that subpage must immediately update values rendered by the main page. Leave propagation at `Subpage` when the parent has no dependent presentation to avoid unnecessary refreshes.

See sample: `updatepropagation-both-refreshes-main-page.good.al`.

## Anti Pattern

Displaying a line-dependent total on the main page while the editable lines part updates only itself. The persisted values can be correct while the parent page continues to show an old total.

See sample: `updatepropagation-both-refreshes-main-page.bad.al`.

## Reference

[Set different control properties](https://learn.microsoft.com/en-us/training/modules/work-with-pages/8-controls)
