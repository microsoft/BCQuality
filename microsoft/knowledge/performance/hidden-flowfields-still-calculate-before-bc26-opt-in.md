---
bc-version: [all]
domain: performance
keywords: [flowfield, visible, page-control, calculate-only-visible-flowfields, feature-management, hidden-field]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Hidden page FlowFields still calculate unless visible-only calculation is enabled

## Description

By default, a FlowField used directly as a page control's source is calculated when the page loads even when `Visible = false` or its visibility expression evaluates to false. The hidden control can therefore issue an aggregate query that no user sees. Business Central 26 introduced the **Calculate only visible FlowFields** feature-management option; only environments with that option enabled skip calculation for controls that are not visible.

## Best Practice

On BC 26 and later, enable and verify the visible-only FlowField feature before relying on `Visible` to suppress calculation. When the target environment does not guarantee that option, avoid binding an expensive FlowField directly to a usually-hidden control: calculate it only in the branch that displays it and bind the page control to a variable. Do not flag a hidden FlowField when the v26 feature is known to be enabled or the FlowField is cheap and intentionally preloaded.

See sample: `hidden-flowfields-still-calculate-before-bc26-opt-in.good.al`.

## Anti Pattern

Adding a costly Sum or Lookup FlowField to a page with `Visible = SomeRareMode` and assuming the hidden state prevents its query on all supported versions. The review signal is the direct FlowField source plus conditional or false visibility, not visibility alone.

See sample: `hidden-flowfields-still-calculate-before-bc26-opt-in.bad.al`.
