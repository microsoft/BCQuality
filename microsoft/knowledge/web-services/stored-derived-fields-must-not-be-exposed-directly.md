---
bc-version: [all]
domain: web-services
keywords: [api-page, derived-fields, exposure, odata]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Recalculate Stored Derived Fields Before Exposing Them on API Pages

> Contributions welcome — open a PR to refine or extend this article.

## Description

A stored field whose value is derived from other fields inside an `OnValidate` trigger only updates when that specific trigger fires. If the underlying source data changes through some other path, the stored value goes stale without raising any error. Exposing such a field directly on an API page hands external consumers a snapshot that may be significantly out of date.

## Best Practice

Recalculate the derived value in `OnAfterGetRecord` from its authoritative source — typically a FlowField — using a page-level variable, and expose both the recalculated value and the source field so the consumer can verify it.

See sample: `stored-derived-fields-must-not-be-exposed-directly.good.al`.

## Anti Pattern

Exposing the stored field directly via `Rec`, trusting that it was kept in sync by whichever trigger last touched it.

See sample: `stored-derived-fields-must-not-be-exposed-directly.bad.al`.
