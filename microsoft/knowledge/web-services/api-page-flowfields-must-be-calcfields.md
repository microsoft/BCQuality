---
bc-version: [all]
domain: web-services
keywords: [api-page, flowfield, calcfields, odata]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Explicitly Calculate FlowFields on API Pages

> Contributions welcome — open a PR to refine or extend this article.

## Description

FlowFields are not stored in the database — Business Central computes them on demand. Regular pages trigger that calculation automatically while rendering, but API pages do not. A FlowField referenced in an API page's layout returns an empty value to external consumers unless it is calculated explicitly, producing a silent data gap in OData responses that is easy to miss in review.

## Best Practice

Call `CalcFields` for every FlowField referenced in the page layout from the `OnAfterGetRecord` trigger, combining multiple fields into a single call.

See sample: `api-page-flowfields-must-be-calcfields.good.al`.

## Anti Pattern

Relying on the implicit calculation that regular pages perform. Any FlowField left out of the `CalcFields` call returns a blank value to every API consumer with no visible error.

See sample: `api-page-flowfields-must-be-calcfields.bad.al`.
