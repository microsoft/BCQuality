---
bc-version: [21..]
domain: ui
keywords: [actionref, promoted-actions, area-promoted, promotedcategory, promotedonly, action-bar, legacy-syntax]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Promote Actions With The Modern `actionref` Syntax, Never The Legacy `Promoted` Properties

## Description
Business Central 2022 release wave 2 (v21) introduced the `area(Promoted)` block with `actionref` as the way to promote page actions, separating an action's definition from its promotion. The older approach set `Promoted`, `PromotedCategory`, `PromotedOnly`, and `PromotedIsBig` directly on each action. The two syntaxes cannot be mixed within a single page or page extension, and choosing the legacy one entangles definition with presentation, making the action bar harder to maintain and to extend.

## Best Practice
For new pages and page extensions, define actions in their normal `area`, then promote selected ones with `actionref` inside `area(Promoted)`, grouping them under explicit categories such as `Category_Process` and entity-named groups. This keeps each action defined once and referenced where it should appear, supports split buttons via `ShowAs`, and lets an extension promote a base action without redefining it. When extending a page, you may use modern syntax even if the base page used legacy properties (and vice versa) — the no-mixing rule is per-object, not per-dependency-tree.

## Anti Pattern
Setting `Promoted = true` (with `PromotedCategory`, `PromotedOnly`, or `PromotedIsBig`) on actions in new code, or attempting to combine those properties with an `area(Promoted)` block in the same object — the latter fails to compile. The reviewer signal is any `Promoted`-prefixed property on an action in a newly authored page or page extension; flag it and convert to `actionref` (VS Code offers an automated conversion). Note separately that once an action is promoted in a published app, removing the promotion is a breaking change (AS0031/AW0013), so promote conservatively rather than walking it back later.
