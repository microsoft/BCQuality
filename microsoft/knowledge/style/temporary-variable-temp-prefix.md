---
bc-version: [all]
domain: style
keywords: [temporary, temp, prefix, record-variable, naming]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefix temporary record variables with `Temp`

## Description

A `Record` variable declared with the `temporary` modifier behaves nothing like a normal record variable: it never touches the database, holds rows only for the lifetime of the variable, and is not visible to filters or queries on the underlying table. The BC convention is to make that difference visible at every call site by prefixing the variable name with `Temp` — `TempJobWIPBuffer`, `TempSalesLine`, `TempIntegerBuffer`. The convention is load-bearing for code review: when a reader sees `SalesLine.Insert()`, they expect a database write; when they see `TempSalesLine.Insert()`, they know it is an in-memory buffer.

## Best Practice

Every local or global variable of type `Record X temporary` must start with `Temp`. Ordinary procedure parameters follow the same convention. Event publisher parameters are owned by the events-domain rule `prefix-temporary-record-event-parameters-with-temp.md`; the style leaf must not emit a second finding for the same event parameter.

See sample: `temporary-variable-temp-prefix.good.al`.

## Anti Pattern

`WIPBuffer: Record "Job WIP Buffer" temporary;` as a local, global, or ordinary procedure parameter reads at the call site as if it were a database operation. Exclude event publisher parameters here so the events leaf remains their single owner.

See sample: `temporary-variable-temp-prefix.bad.al`.
