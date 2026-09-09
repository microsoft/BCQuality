---
bc-version: [all]
domain: performance
keywords: [recordref, fieldref, hot-loop, typed-record, metadata]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Avoid RecordRef / FieldRef in hot loops when a typed record fits

## Description

`RecordRef` and `FieldRef` are slower than direct typed record access — the platform resolves the table and field at runtime instead of at compile time. The trade-off is intentional: per the upstream guidance, "RecordRef/FieldRef operations are slower than direct record access, but many features REQUIRE them for generic metadata iteration (permission checks, field copying, dynamic field access)." The rule, then, is not "never use them" but "only flag when used inside a clearly unbounded hot loop (10k+ iterations) where a typed alternative exists."

## Best Practice

Use `RecordRef`/`FieldRef` for genuinely generic code — permission checks, field copying, table-agnostic export. When the loop target is known at compile time and the loop iterates a large number of rows, declare the typed record and access fields directly; the saved per-iteration overhead is measurable at the volumes the rule targets.

See sample: [`avoid-recordref-in-hot-loop.good.al`](avoid-recordref-in-hot-loop.good.al).

## Anti Pattern

`RecRef.Open(Database::Customer); if RecRef.FindSet() then repeat FldRef := RecRef.Field(Customer.FieldNo(Name)); ProcessName(FldRef.Value); until RecRef.Next() = 0;` — the table is fixed at compile time, the field is fixed at compile time, and the loop pays the dynamic-resolution cost on every iteration. The direct `Customer.Name` form does the same work without the lookup.

See sample: [`avoid-recordref-in-hot-loop.bad.al`](avoid-recordref-in-hot-loop.bad.al).
