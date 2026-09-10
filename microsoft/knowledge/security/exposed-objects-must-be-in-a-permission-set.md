---
bc-version: [all]
domain: security
keywords: [permission-set, api-page, web-service, exposure, access-control]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Every exposed object must belong to a permission set

## Description

An object that is reachable from outside the app's own UI is only usable if it is also granted execute access through a permission set. Three distinct mechanisms make an object reachable this way, each with its own permission target:

- A page or query published through the **Web Services** configuration page, or a custom REST endpoint declared with `PageType = API` / `QueryType = API` — both need a `page "..." = X` / `query "..." = X` entry for that object.
- A codeunit published through **Web Services** exposes *every* public procedure on it as an OData/SOAP operation automatically — there is no per-method attribute to add. The permission target is the codeunit itself: `codeunit "..." = X`.
- `[ServiceEnabled]` is a method-level attribute used on a *page* procedure to expose it as an OData v4 bound action (for example a `Post` action on an invoice page) — it does not apply to pages, queries, or codeunits as an object-level property, and it does not create its own permission target. The action is still a call into that page object, so the page's own `page "..." = X` entry is what governs it.

When such an object is left out of every permission set, it becomes both unusable (no caller, human or service, can reach it) and invisible in review: nobody deliberately decided who may call it. Exposure without a matching grant is not a safe default; it is an endpoint nobody is governing.

## Best Practice

Give every exposed object an explicit execute entry in a permission set shipped by the app: `page "..." = X` / `query "..." = X` for a published or API page/query (including one that exposes a `[ServiceEnabled]` bound action), and `codeunit "..." = X` for a codeunit published as a web service. Route sensitive endpoints into a dedicated, non-default admin permission set so reaching them requires a deliberate grant rather than being included by default. If an object should never be reachable from outside the app, remove the exposure itself (drop `PageType = API` / the Web Services registration) rather than leaving an orphaned endpoint with no permission-set membership.

See sample: `exposed-objects-must-be-in-a-permission-set.good.al`.

## Anti Pattern

Granting access to the underlying table data while forgetting to grant execute access to the exposed page or query itself. The table looks fully covered by a permission set, but the API/service layer in front of it has no `= X` entry anywhere, so the endpoint silently fails for every caller even though the data permissions look complete.

See sample: `exposed-objects-must-be-in-a-permission-set.bad.al`.
