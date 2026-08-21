---
bc-version: [all]
domain: performance
keywords: [guiallowed, clienttype, odata, edit-in-excel, page-trigger, factbox]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Guard page trigger work with GuiAllowed for OData and Excel

> Contributions welcome — open a PR to refine or extend this article.

## Description

Pages exposed as OData, including Edit in Excel, still run AL page triggers for every row returned. FactBox updates, defaulting, and extra `CalcFields` in `OnAfterGetRecord` therefore run on the web-service path where no UI exists. `GuiAllowed` is false for those sessions. Agents add page logic as if only the browser client will execute it.

## Best Practice

Wrap UI-only work — FactBox refresh, notifications, defaulting that is not part of the web-service contract — in `if GuiAllowed then`. Keep the OData path to field values the API actually returns.

See sample: `guiallowed-guard-on-pages-used-as-odata.good.al`.

## Anti Pattern

Unconditional FactBox or calculation logic in `OnAfterGetRecord` / `OnAfterGetCurrRecord` on a page that is published as a web service or used with Edit in Excel. The signal is trigger work that calls `CurrPage` parts or extra queries without a `GuiAllowed` guard.

See sample: `guiallowed-guard-on-pages-used-as-odata.bad.al`.
