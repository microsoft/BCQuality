---
bc-version: [all]
domain: security
keywords: [istemporary, deleteall, modifyall, safeguard, precondition]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Guard bulk operations with IsTemporary

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

An AL helper that accepts a `var Rec: Record X` parameter and performs a bulk operation (`DeleteAll`, `ModifyAll`, or an unfiltered loop that mutates every record) cannot tell from the signature alone whether the caller passed a temporary buffer or the real table. A misuse that passes the real table wipes or rewrites live data at production scale with no earlier warning. A single `IsTemporary` check at the procedure entry turns a silent-corruption risk into an early, actionable failure.

## Best Practice

Any helper designed to operate on a temporary record, and that performs `DeleteAll`, `ModifyAll`, or similar bulk writes on its parameter, should call `Rec.IsTemporary()` at the top and raise a descriptive error when the assumption is violated. The error message should name the parameter so the misuse is easy to locate.

See sample: `guard-bulk-operations-with-istemporary.good.al`.

## Anti Pattern

Trusting documentation or naming conventions alone to signal that a `var Rec` parameter is expected to be temporary. A future refactor or a copy-paste caller can pass the real table; the bulk operation then executes against production rows silently.

See sample: `guard-bulk-operations-with-istemporary.bad.al`.
