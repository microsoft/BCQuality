---
bc-version: [all]
domain: performance
keywords: [dictionary, temporary-table, lookup, o-of-1, key-lookup]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefer a Dictionary over a temporary table for pure lookups

## Description

An AL `Dictionary` directly models an unordered unique key-to-value collection. A temporary table models records and supports keys, filters, validation, and ordered iteration in Business Central Server memory. For a pure lookup map, the dictionary avoids repeatedly configuring and searching a temporary record and makes the intended access pattern explicit.

## Best Practice

Use `Dictionary of [Key, Value]` when the operation is add-or-replace, contains-key, and get-value by one supported key type. Use a temporary table when the value is a record, or when the code needs filters, ordered iteration, multiple fields, multiple keys, or table behavior. Both structures consume service-tier memory and still need volume analysis.

## Anti Pattern

A temporary record used only through `SetRange(KeyField, X); FindFirst()` to retrieve one scalar value, with no record semantics that justify the table. The opposite mistake is replacing a temporary table that needs filtering or ordered iteration with a dictionary.
