---
bc-version: [all]
domain: performance
keywords: [n-plus-one, get, findfirst, loop, inner-lookup, large-table]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Avoid Get / FindFirst inside a loop on a large inner table

## Description

A `Get` or `FindFirst` against another persistent table inside a loop can produce an N+1 access pattern: one outer query followed by repeated inner lookups. Server and primary-key caches can satisfy some `Get` calls, so a source-level `Get` is not proof of one SQL round-trip. The concern is an unbounded loop whose lookup keys are not known to repeat or remain cached.

## Best Practice

Use a query object to join the outer and inner tables when the relationship and filters can be expressed as one query. If keys repeat, a dictionary cache can reduce lookups to one per distinct key. `SetLoadFields` can reduce the columns transferred by unavoidable inner reads, but it does not eliminate the N+1 shape and must not be presented as doing so.

See sample: `avoid-get-inside-loop-on-large-table.good.al`.

## Anti Pattern

Iterating production BOM lines and calling `Item.Get(BOMLine."No.")` for each line when the same result can be produced by a query joining Production BOM Line to Item. Partial loading alone is only a payload mitigation for this pattern.

See sample: `avoid-get-inside-loop-on-large-table.bad.al`.
