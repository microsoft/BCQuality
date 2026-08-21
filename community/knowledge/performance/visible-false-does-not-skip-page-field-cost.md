---
bc-version: [all]
domain: performance
keywords: [visible, enabled, page-field, list-page, metadata, hidden-control]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Visible false does not skip page-field cost

> Contributions welcome — open a PR to refine or extend this article.

## Description

`Visible = false` and `Enabled = false` hide a control; they do not remove it from the page metadata the client and server still process. List pages in particular still load bound fields and can still calculate FlowFields on those controls — see `hidden-flowfields-still-calculate-before-bc26-opt-in.md` for the FlowField-specific opt-in. Official page-performance guidance is to **delete** the field from the page object when users do not need it. Agents hide heavy columns instead of removing them.

## Best Practice

If a list or card should not pay for a column, omit the field from the page (or page extension) layout. Use `Visible` only for controls that must exist for some users or modes and whose cost is acceptable when hidden. Do not treat `Visible = false` as a performance fix.

See sample: `visible-false-does-not-skip-page-field-cost.good.al`.

## Anti Pattern

Adding an expensive bound field or FlowField to a list and setting `Visible = false` "so it does not run". The control remains in the page definition. The signal is a hidden bound field whose only purpose was to avoid showing data, not to toggle a real mode.

See sample: `visible-false-does-not-skip-page-field-cost.bad.al`.
