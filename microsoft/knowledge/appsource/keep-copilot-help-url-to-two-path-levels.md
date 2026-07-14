---
bc-version: [27..]
domain: appsource
keywords: [app-json, help-url, copilot, grounding, documentation, url-depth, contexturl]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep the Copilot help URL to two path levels

## Description

The `help` URL declared in `app.json` is what Copilot uses to ground answers about your app. That URL may be at most **two path levels** deep (for example `https://contoso.com/docs/myapp`). If you point it at a deeper path (three or more segments), Copilot does not use the URL as given: it truncates to the first two levels, drops any fragments and query strings, and then grounds on **all** content beneath that two-level path. The failure is silent — there is no build error — and the practical effect is worse answers, because Copilot may ingest sibling apps' documentation that lives under the same two-level parent.

## Best Practice

Organize per-app documentation so the canonical help page sits no deeper than two path levels, and confirm during testing that Copilot citations resolve to your app's content rather than a broader parent. If your docs naturally nest deeper, give each app a dedicated two-level path it owns.

## Anti Pattern

Setting `help` to a deep, tidy-looking docs path such as `https://contoso.com/docs/products/erp/myapp/setup`. Copilot truncates it to `…/docs/products`, then grounds on everything under that node — pulling in unrelated content and degrading answer quality for your users.
