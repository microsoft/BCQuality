---
bc-version: [all]
domain: upgrade
keywords: [obsolete-state, obsolete-reason, obsolete-tag, deprecation, metadata]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Give every obsolete element a reason and tag

## Description

AL has two obsoletion mechanisms, depending on the symbol:

- Objects, fields, enum types, and enum values use the `ObsoleteState`, `ObsoleteReason`, and `ObsoleteTag` properties. `Pending` warns while the element remains available; `Removed` blocks references.
- Methods, variables, events, and other symbols use `[Obsolete('reason', 'tag')]`. They do not have an `ObsoleteState` property.

In both forms, the reason should name the replacement and the tag should identify when the element became obsolete. Empty or missing guidance leaves consumers without an actionable migration path.

## Best Practice

For an object or field, set all three properties together. For a method, variable, or event, provide both `[Obsolete]` arguments. Keep the original tag stable through the lifecycle rather than changing it to a planned removal version.

See sample: `obsoletion-requires-reason-and-tag.good.al`.

## Anti Pattern

Setting only `ObsoleteState = Pending`/`Removed` on an object or field, or using `[Obsolete('', '')]` on a method, variable, or event. Both forms produce deprecation metadata without useful replacement guidance or traceability.

See sample: `obsoletion-requires-reason-and-tag.bad.al`.

## See also

- `obsolete-pending-to-removed-staging.md` — when to advance `Pending` to `Removed` and write upgrade code.
