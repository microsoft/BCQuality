---
bc-version: [all]
domain: appsource
keywords: [pageextension, actions, addfirst, addlast, addbefore, addafter]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Place page extension actions with addfirst or addlast

## Description

Place new page-extension actions at the beginning or end of an existing action group with `addfirst` or `addlast`. Anchoring a new action relative to a specific base-app action with `addbefore` or `addafter` couples the extension to an implementation detail that can move or disappear between Business Central releases.

## Best Practice

Choose the semantic action area or group and append or prepend the extension's actions. This keeps placement deterministic without depending on the continued existence of one neighboring action.

See sample: `place-page-extension-actions-with-addfirst-or-addlast.good.al`.

## Anti Pattern

Using `addbefore` or `addafter` to place newly added actions next to a specific action from another app. The syntax is valid AL, but the placement anchor is brittle for an AppSource extension.

See sample: `place-page-extension-actions-with-addfirst-or-addlast.bad.al`.