---
bc-version: [all]
domain: style
keywords: [api-page, apiversion, version, format, beta]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `APIVersion` must follow the pattern `vX.Y` (or `beta`)

## Description

The `APIVersion` property on an API page is part of the public URL path: `/api/<publisher>/<group>/<version>/<entitySetName>`. The platform accepts only two value shapes for it: a `vMAJOR.MINOR` string such as `'v1.0'`, `'v2.0'`, or `'v2.1'`, or the literal string `'beta'` for pre-release endpoints. Anything else — `'v2'`, `'2.0'`, `'1'`, `'v2.0.0'` — is rejected. The major-minor pair lets consumers detect compatibility through URL inspection alone; the explicit `'beta'` channel signals "this contract may break without notice."

## Best Practice

Start a new public endpoint at `'v1.0'`. Bump the minor when adding fields or non-breaking changes; bump the major when changing field types, removing fields, or any breaking change. Use `'beta'` for endpoints that are still iterating and SHOULD NOT be consumed by external integrations.

See sample: [`api-page-version-format.good.al`](api-page-version-format.good.al).

## Anti Pattern

`APIVersion = 'v2'` (missing minor), `APIVersion = '2.0'` (missing `v` prefix), `APIVersion = 'v2.0.0'` (extra segment). All three either fail to compile or produce a URL that consumers cannot reach.

See sample: [`api-page-version-format.bad.al`](api-page-version-format.bad.al).
