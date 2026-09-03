---
bc-version: [all]
domain: performance
keywords: [currpage-update, onaftergetrecord, list-page, scroll, refresh]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not call CurrPage.Update inside OnAfterGetRecord

> Contributions welcome — open a PR to refine or extend this article.

## Description

`OnAfterGetRecord` on a list already runs once per visible row on scroll and refresh. `CurrPage.Update` asks the page to reload, which fires those triggers again. The result is a refresh loop or a stutter on every row paint. Official developer performance guidance lists `CurrPage.Update()` in `OnAfterGetRecord` next to `Modify` as work that must not live there. Sibling of `do-not-modify-in-onaftergetrecord.md` (writes); this file is the client refresh half.

## Best Practice

Put display-only results in page variables assigned in `OnAfterGetRecord` without calling `Update`. If the page must refresh after an action, call `CurrPage.Update(false)` from `OnAction` once, not per row.

See sample: `avoid-currpage-update-in-onaftergetrecord.good.al`.

## Anti Pattern

`trigger OnAfterGetRecord() begin ... CurrPage.Update(); end;` on a list. The signal is `CurrPage.Update` inside `OnAfterGetRecord` or `OnAfterGetCurrRecord` without an explicit user action.

See sample: `avoid-currpage-update-in-onaftergetrecord.bad.al`.
