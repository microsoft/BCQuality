---
bc-version: [all]
domain: performance
keywords: [modifyall, bulk-update, filter, scan, recordset]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Combine multiple ModifyAll calls on the same recordset into a single pass

## Description

`ModifyAll(Field, Value)` issues a SQL UPDATE against every row matching the record variable's current filters, setting one field. Calling it twice on the same filtered recordset — once per field to update — produces two separate UPDATE statements, each of which has to re-locate the matching rows through the index. On a ledger-entry-scale table with ten million rows and a filter that matches a thousand, the overhead is not a doubling of the update cost but a doubling of the more expensive row-location cost. A single `FindSet(true)` + set-by-set assignment + `Modify(false)` completes both field changes in one pass.

## Best Practice

When more than one field needs to change on the same filtered recordset, iterate once with `FindSet(true)` and assign all fields per row. Reserve ModifyAll for the case where a single field change covers the whole update. If the filter set is truly huge and the trigger behaviour differs between fields, consider splitting with concrete evidence — otherwise the single-pass loop wins.

See sample: `combine-multiple-modifyall-calls.good.al`.

## Anti Pattern

Applying `SetRange` against `CustLedgerEntry` on `"Document No."` and then calling `ModifyAll("Accepted Payment Tolerance", ...)` followed by `ModifyAll("Accepted Pmt. Disc. Tolerance", false)` — two scans over the same filtered rows. On Cust. Ledger Entry with production-scale data the redundant second scan is the dominant cost.

See sample: `combine-multiple-modifyall-calls.bad.al`.
