---
bc-version: [21..]
domain: style
keywords: [abouttitle, abouttext, teaching-tip, onboarding, page]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use `AboutTitle` and `AboutText` to surface teaching tips on top-level pages

## Description

The `AboutTitle` and `AboutText` properties on a page render a teaching tip — an onboarding callout that appears the first time a user opens the page. They are supported on pages, individual page controls, FactBoxes, and report request pages. They are NOT supported on Role Centers or modal dialogs. The conventions: `AboutTitle` answers "what is this page about?" and uses the plural for list pages (`'About sales invoices'`) and the `[entity] details` form for card and document pages (`'About sales invoice details'`); `AboutText` answers "what can I do with this page?" in two or three short sentences. Both are translation-aware and surface to the end user verbatim.

The reviewer signal is "this is a new top-level card or list page in an app whose sibling pages already define teaching tips" — when the surrounding app sets the precedent, a new page without `AboutTitle`/`AboutText` is an inconsistency worth flagging.

## Best Practice

Set `AboutTitle` and `AboutText` on every new top-level card, list, and document page in an app that already uses them. Keep `AboutText` to two or three short sentences. Describe what the page does, not the navigation steps to use it — teaching tips explain WHAT, not HOW.

See sample: `abouttitle-abouttext-teaching-tips.good.al`.

## Anti Pattern

A new top-level page in an app whose siblings have `AboutTitle`/`AboutText`, but with no teaching tips defined. Equally wrong is filling `AboutText` with step-by-step instructions ("Click New, then enter…") — the property is for orientation, not procedural help.

See sample: `abouttitle-abouttext-teaching-tips.bad.al`.
