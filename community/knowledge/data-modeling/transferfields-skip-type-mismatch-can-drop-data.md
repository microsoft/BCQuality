---
bc-version: [16..]
domain: data-modeling
keywords: [transferfields, skipfieldsnotmatchingtype, type-mismatch, field-mapping, data-transfer]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not use SkipFieldsNotMatchingType to hide required TransferFields mismatches

## Description

`Record.TransferFields` copies values between fields with matching field numbers. Without `SkipFieldsNotMatchingType` (or with it `false`), a type mismatch between two fields in the same extension raises a runtime error at the point of transfer. Setting `SkipFieldsNotMatchingType` to `true` removes that error: the field is skipped instead, and the rest of the transfer completes normally. The caller gets no indication that a field was not copied.

## Best Practice

Use `TransferFields(Source)` only when every field the destination requires, including primary key fields, is guaranteed to share a matching field number and type with the source; this form defaults `InitPrimaryKeyFields` to `true`. Fields with no matching field number, and fields whose types differ across extensions, are skipped regardless of `SkipFieldsNotMatchingType` — that parameter only governs same-extension type mismatches. If the destination depends on a field that falls into either case, map and validate it explicitly in code rather than relying on `TransferFields` to catch the gap. Use `SkipFieldsNotMatchingType = true` only when skipping same-extension type mismatches is an intentional, documented part of the transfer contract.

See sample: `transferfields-skip-type-mismatch-can-drop-data.good.al`.

## Anti Pattern

Using `TransferFields(Source, InitPrimaryKeyFields, true)` as a generic way to make two evolving table schemas transfer without errors, when the destination depends on every required source field being copied. A type change on either table can turn a previously transferred field into a silently skipped one without making the transfer itself fail.

See sample: `transferfields-skip-type-mismatch-can-drop-data.bad.al`.