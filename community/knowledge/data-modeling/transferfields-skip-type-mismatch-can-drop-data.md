---
bc-version: [all]
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

Use `TransferFields(Source)` when matching field definitions are an expected part of the table design. If source and destination fields intentionally have different types, map those fields explicitly and handle the conversion or validation in code. Use `SkipFieldsNotMatchingType = true` only when skipping incompatible fields is an intentional, documented part of the transfer contract.

## Anti Pattern

Using `TransferFields(Source, InitPrimaryKeyFields, true)` as a generic way to make two evolving table schemas transfer without errors, when the destination depends on every required source field being copied. A type change on either table can turn a previously transferred field into a silently skipped one without making the transfer itself fail.

See sample: `transferfields-skip-type-mismatch-can-drop-data.good.al`.

See sample: `transferfields-skip-type-mismatch-can-drop-data.bad.al`.