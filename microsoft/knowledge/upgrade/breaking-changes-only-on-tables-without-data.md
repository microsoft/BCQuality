---
bc-version: [all]
domain: upgrade
keywords: [primary-key, field-type, breaking-change, integer-to-biginteger, existing-data]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Distinguish supported field widening from breaking schema changes

## Description

Not every field-type change is an unsupported schema break. Starting with runtime 18.0 (BC 29 / 2026 release wave 2), the platform supports widening an existing table field from `Integer` to `BigInteger`, including a ledger's `Entry No.`, while retaining existing data. This does not authorize narrowing, arbitrary type conversions, or changing the primary-key field list. A new table's initial schema remains free to choose; changes to published tables must be assessed against the actual platform-supported upgrade rules.

## Best Practice

On runtime 18.0+, widen an existing `Integer` field to `BigInteger` in place when needed, retaining its field ID and the existing primary/clustered key field list and order. Do not require a replacement table, deletion of ledger data, force synchronization, `DataTransfer`, or an upgrade tag solely for this supported conversion. Before runtime 18.0, do not assume the conversion is supported.

Review deployment impact and dependent code separately. Related identifier fields, register bounds, variables, procedure parameters, and returns must accommodate the widened values; existing `Integer` consumers can still overflow above 2,147,483,647. AS0146 is a warning about dependent-extension compatibility, not a blanket prohibition on the field conversion.

For unsupported schema changes, preserve the published schema or design a supported migration, such as a replacement table populated by upgrade code with `DataTransfer` and an upgrade tag. Merely adding an upgrade codeunit does not legalize an otherwise rejected field or key edit. [Changing a published key's field list](../data-modeling/do-not-change-primary-key.md) remains a separate breaking change.

See sample: [`breaking-changes-only-on-tables-without-data.good.al`](breaking-changes-only-on-tables-without-data.good.al).

## Anti Pattern

Narrowing a published `BigInteger` field to `Integer`, changing the published primary-key field list, or assuming arbitrary type conversions are supported because the target table is empty in a test tenant. Conversely, rejecting supported runtime 18.0+ `Integer`-to-`BigInteger` widening merely because the table contains data is a false positive.

See sample: [`breaking-changes-only-on-tables-without-data.bad.al`](breaking-changes-only-on-tables-without-data.bad.al).

## References

- [AS0146: field widening from runtime 18.0 and dependent-extension caveats](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/analyzers/appsourcecop-as0146).
- [Base Application ledger entry numbers expanded to 64 bit](https://github.com/microsoft/BCApps/pull/10834).
