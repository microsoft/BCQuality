---
bc-version: [all]
domain: web-services
keywords: [api-page, serviceenabled, bound-action, webserviceactioncontext, setactionresponse, side-effect, patch]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Expose business operations as bound actions, not as writable status flags

## Description

An API consumer that needs to *do* something to a record — post it, ship it, release it — should call an explicit operation, not mutate a field and hope a side effect fires. AL models this with a bound action: a `[ServiceEnabled] procedure` that takes `var ActionContext: WebServiceActionContext`, performs the work, and reports the result through the action context (typically a `SetActionResponse` helper that returns the affected record's id). The endpoint then exposes a callable action — `.../salesOrders(<id>)/Microsoft.NAV.post` — with a clear contract. The anti-pattern is to expose a writable Boolean or status field whose `OnValidate` quietly performs the operation: a routine PATCH that looks like a data edit silently triggers posting, with no discoverable action and surprising, hard-to-audit behaviour. LLMs reach for the flag-field approach because it is less code; this file is remedial because the platform-idiomatic, contract-safe choice (a bound action) is not the model's default.

## Best Practice

Declare the operation as `[ServiceEnabled] procedure Post(var ActionContext: WebServiceActionContext)` on the API page. Inside, perform the operation against `Rec`, then call a `SetActionResponse` helper that writes the result — the bound record and its id — back into the `WebServiceActionContext` so the caller receives a well-formed response. The operation is now an explicit, named endpoint action separate from ordinary field writes.

See sample: `expose-operations-as-bound-actions.good.al`.

## Anti Pattern

Exposing a writable Boolean (for example `posted`) whose `OnValidate` performs the posting. A client that PATCHes the field to `true` — an action indistinguishable from any other data edit — silently triggers a side-effecting business operation. The detection signal: an API page field whose `OnValidate` posts, ships, or releases, instead of a `[ServiceEnabled]` bound action.

See sample: `expose-operations-as-bound-actions.bad.al`.
