---
bc-version: [21..]
domain: ui
keywords: [showas, splitbutton, promoted-actions, actionref, posting-actions, release-action, action-bar]
technologies: [al]
countries: [w1]
application-area: [all]
---
# Reserve `ShowAs = SplitButton` For Standard Posting And Release Groups

> Contributions welcome — open a PR to refine or extend this article.

## Description
Setting `ShowAs = SplitButton` on a `group` inside `area(Promoted)` renders a primary one-click button with a dropdown of related alternatives, where the FIRST `actionref` in the group becomes the primary (left) button. Business Central users have learned this pattern from the two standard groups it ships with — Posting (`Post`, `Post and Print`, `Post and Send`, `Preview Posting`) and Release (`Release`, `Reopen`). Inventing new split-button groups for unrelated actions, or ordering the dropdown so the most common action is not first, breaks that learned muscle memory and makes users guess what the left button will do.

## Best Practice
Use `ShowAs = SplitButton` only when all hold: the actions are genuinely variations of one operation, there is an obvious most-frequent primary, and the dropdown stays at roughly two to four items. Place that primary action as the first `actionref` so it occupies the left button; order the remaining refs by descending frequency. Outside the Posting and Release conventions, treat a new split-button group as something to justify, not a default — a plain promoted group or category is usually the safer choice and keeps the action bar predictable.

## Anti Pattern
Grouping unrelated actions under one split button to save toolbar space — for example pairing `Post` with `Delete`, or `Release` with `Print` — so the left button performs whatever happens to be listed first. The reviewer signal is a group with `ShowAs = SplitButton` whose member `actionref`s do not share a verb or workflow, a primary that is not the most common action, or a dropdown padded well beyond four items. Each makes the immediate left-click unpredictable and costs the user the very click the split button was meant to save.
