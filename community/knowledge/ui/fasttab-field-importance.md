---
bc-version: [all]
domain: ui
keywords: [importance, promoted, additional, fasttab, show-more, summary-line, progressive-disclosure, field-visibility]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Set Field Importance To Drive FastTab Progressive Disclosure

> Contributions welcome — open a PR to refine or extend this article.

## Description
A FastTab field's `Importance` property controls whether the field is visible immediately, hidden behind "Show more", or surfaced on the collapsed FastTab header summary line. The three values are `Standard` (the default, shown in the expanded FastTab), `Promoted` (also rendered on the FastTab header when the tab is collapsed), and `Additional` (hidden until the user clicks "Show more"). Misusing these values either clutters the summary line or buries fields users need on every transaction, so reviewers should treat `Importance` as a deliberate layout decision rather than an afterthought.

## Best Practice
Promote only the two to four identifying fields per FastTab that users must read at a glance without expanding — name, status, key amount — so the collapsed header summary line stays scannable. Leave the everyday working fields at `Standard`, and push rarely-touched fields (legacy compatibility fields, system timestamps, seldom-changed configuration) to `Additional`. Note that field-level `Importance = Promoted` is unrelated to action promotion on the page action bar; it governs FastTab field visibility only. Do not rely on initial expand or collapse state, which you cannot set programmatically and which the platform may personalize per user — design assuming any FastTab may be collapsed.

## Anti Pattern
Setting `Importance = Promoted` on most fields of a FastTab so "everything is important" defeats progressive disclosure: the collapsed summary line overflows and conveys nothing at a glance. The opposite failure is marking frequently edited fields `Additional`, forcing users to click "Show more" on every record. A detectable signal is a FastTab whose fields are nearly all `Promoted`, or a FastTab containing only `Additional` fields, which renders as an empty tab until expanded.
