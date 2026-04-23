---
bc-version: [all]
domain: security
keywords: [validatetablerelation, user-input, lookup, integrity, validation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not set ValidateTableRelation = false on fields that accept user input

## Description

`TableRelation` on a field tells the platform that the value must exist as a primary key in the related table. `ValidateTableRelation = false` suppresses that check at validation time. On system-populated fields — values the code sets from a controlled source and never displays as editable — the suppression is acceptable because the integrity guarantee comes from the upstream writer. On a field the user types into (a page field, an import column, an API payload), disabling the validation means any value at all can be written: a non-existent customer number, a typo, a deliberate bad value. The table no longer enforces the relation, and downstream code that Gets the related row with an unguarded lookup breaks.

## Best Practice

Leave `ValidateTableRelation = true` (the default) on any field the user can set. When the default would produce unhelpful behaviour — a transient lookup that does not yet exist at validation time, a reference that uses a non-primary-key column — handle it with a targeted OnValidate trigger that performs the semantic check explicitly. Use `ValidateTableRelation = false` only when the field is genuinely system-controlled and the writer has already validated the reference.

See sample: `do-not-disable-validatetablerelation-on-user-input.good.al`.

## Anti Pattern

A `Customer No.` field on an editable page with `TableRelation = Customer."No."` and `ValidateTableRelation = false` and no OnValidate fallback. The user can type any string; the platform accepts it; a later Get against Customer fails or returns the wrong row.

See sample: `do-not-disable-validatetablerelation-on-user-input.bad.al`.
