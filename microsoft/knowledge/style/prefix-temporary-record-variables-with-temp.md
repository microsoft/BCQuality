---
bc-version: [all]
domain: style
keywords: [temporary, record, variable, prefix, naming, temp]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefix temporary record variables with "Temp"

## Description

A `Record X temporary` variable behaves differently from a persistent Record variable of the same type: Insert/Modify/Delete mutate an in-memory buffer, not the underlying table. Code that mixes persistent and temporary variables of the same type is a recurring source of data-loss bugs — a helper that does `DeleteAll` on what the caller believed was a temporary buffer wipes the real table. The convention across Business Central is to prefix every temporary record variable with `Temp` (`TempJobWIPBuffer`, `TempSalesLine`, `TempCustomer`) so the distinction is visible at every read site, not only at the declaration.

## Best Practice

Prefix every temporary-record variable with `Temp`. The prefix goes on the variable name, not the type; the `temporary` keyword remains on the declaration. Matching the prefix against the declaration makes it a one-line check in code review: if the name starts with `Temp`, the declaration ends in `temporary`, and vice versa.

See sample: `prefix-temporary-record-variables-with-temp.good.al`.

## Anti Pattern

`WIPBuffer: Record "Job WIP Buffer" temporary` — the variable reads like a persistent record in every call site below the declaration. A reviewer scanning a mutation call (`WIPBuffer.DeleteAll()`) cannot tell from the call site whether the effect is in-memory or production.

See sample: `prefix-temporary-record-variables-with-temp.bad.al`.
