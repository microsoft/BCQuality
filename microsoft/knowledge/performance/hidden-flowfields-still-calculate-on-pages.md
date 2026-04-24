---
bc-version: [all]
domain: performance
keywords: [flowfield, visible, enabled, page, calcfields, feature-management]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Hidden FlowFields still calculate on pages

## Description

Setting `Visible = false` or `Enabled = false` on a FlowField hides the control but does not suppress the calculation. The server still runs the underlying CalcFields for every row the page renders. On a list page over a large table, the invisible column keeps consuming the same SQL as a visible one — the hiding is cosmetic only, and a diff that "turns off" an expensive FlowField by flipping `Visible` fixes nothing on the server.

There are two correct remedies. The durable one is to remove the FlowField from the page or page-extension definition entirely — property toggles are not enough. The environment-level one, available where supported, is the **Calculate only visible FlowFields** feature in Feature Management; when enabled, the AL runtime skips calculation for non-visible FlowFields on pages. The feature is opt-in and administrator-controlled, so code cannot assume it is active.

## Best Practice

Remove unused or hidden FlowFields from the page or page extension. If the field is needed for some users but expensive for others, factor into a dedicated page variant rather than hiding it in place. Do not rely on `Visible = false` as a performance fix unless the tenant has enabled the Calculate only visible FlowFields feature and that assumption is acceptable.

## Anti Pattern

A performance PR that sets `Visible = false` on an expensive FlowField on a list page and claims the column no longer impacts load time. The control disappears from the UI, the CalcFields still runs for every row, and the list page stays slow.
