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

Severity must scale with the inner table, not just the presence of `Get` inside a loop. A `Get` against a small, bounded master/setup table (for example Allocation Account, Payment Terms, Currency, Number Series — tables with at most a few hundred rows) is not the "large table" anti-pattern this article targets: the row count of the inner table caps total lookup cost regardless of how many outer records are processed, and repeated lookups of the same handful of keys are cheap. Do not raise this to High severity solely because a `Get` sits inside a loop over a large outer set; the outer set size is irrelevant when the inner table itself is small. Also credit an existing guard: a `Get` executed only when an optional foreign-key field is non-blank (`if Rec."Some Code" <> '' then if OtherTable.Get(Rec."Some Code") then ...`) already limits calls to rows that actually reference the inner table, further reducing this to a low-severity, case-by-case observation rather than an unconditional N+1.

## Best Practice

Use a query object to join the outer and inner tables when the relationship and filters can be expressed as one query. If keys repeat, a dictionary cache can reduce lookups to one per distinct key. `SetLoadFields` can reduce the columns transferred by unavoidable inner reads, but it does not eliminate the N+1 shape and must not be presented as doing so. Reserve this recommendation, and High severity, for genuinely large inner tables (thousands of rows and growing); for small bounded master/setup tables, a passing note about caching by key is enough — do not demand a joined query rewrite.

See sample: `avoid-get-inside-loop-on-large-table.good.al`.

## Anti Pattern

Iterating production BOM lines and calling `Item.Get(BOMLine."No.")` for each line when the same result can be produced by a query joining Production BOM Line to Item. Partial loading alone is only a payload mitigation for this pattern.

See sample: `avoid-get-inside-loop-on-large-table.bad.al`.
