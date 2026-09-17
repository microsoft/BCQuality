---
bc-version: [all]
domain: upgrade
keywords: [obsolete-reason, obsolete-tag, deprecation, version, metadata, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# ObsoleteReason need not restate the removal version; ObsoleteTag carries it

## Description

An obsoleted object, field, key, enum, or enum value carries both `ObsoleteReason` and `ObsoleteTag`, and the two properties have different jobs. `ObsoleteReason` is free text that explains why the element is obsolete and what replaces it. `ObsoleteTag` identifies when it became obsolete — typically the version, release, or work item that introduced the obsoletion. The version traceability lives in `ObsoleteTag`; there is no requirement that `ObsoleteReason` also name the removal version or repeat what the tag already records. A reason that omits a version number is complete as long as it explains the deprecation and points to a replacement, provided `ObsoleteTag` pins the version.

## Best Practice

When `ObsoleteTag` already carries the version or tracking reference, do not flag `ObsoleteReason` for not mentioning a version or removal release. Judge `ObsoleteReason` on whether it explains the deprecation and names a replacement, and judge version traceability on `ObsoleteTag` instead.

## Anti Pattern

Flagging an `ObsoleteReason` as vague, incomplete, or missing a version reference solely because it does not restate the removal version, when `ObsoleteTag` already records that version. Requiring the reason to duplicate the tag's version is not a real convention.

## See also

- `obsoletion-requires-reason-and-tag.md` — both properties are required; the reason names the replacement and the tag identifies when the element became obsolete.
