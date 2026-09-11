---
bc-version: [all]
domain: performance
keywords: [isempty, count, findfirst, existence-check, exists]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use IsEmpty for existence checks, not Count() or FindFirst()

## Description

When the caller only needs to know whether any row matches a filter, `IsEmpty()` is the API designed for the question. Per the upstream guidance, "`IsEmpty()` is more efficient as it stops at first record found." `Count() > 0` materializes a count the caller does not need; `FindFirst()` materializes a row the caller does not need. Both do work that `IsEmpty` does not.

## Best Practice

Phrase existence checks as `if not Record.IsEmpty() then ...` (or `if Record.IsEmpty() then ...` for the negative). Apply filters via `SetRange`/`SetFilter` before the call so the existence check runs against the intended subset. Reserve `Count` for cases where the actual number matters and `FindFirst` for cases where the record fields are read.

See sample: [`use-isempty-for-existence-check.good.al`](use-isempty-for-existence-check.good.al).

## Anti Pattern

`if Customer.Count() > 0 then ...` and `if Customer.FindFirst() then ...` (when the record is discarded) — both are flagged by the upstream guidance as the wrong tool. The first asks the database for the full count; the second asks for a row's fields. Both answers go unused.

See sample: [`use-isempty-for-existence-check.bad.al`](use-isempty-for-existence-check.bad.al).
