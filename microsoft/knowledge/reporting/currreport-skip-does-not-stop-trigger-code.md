---
bc-version: [all]
domain: reporting
keywords: [report, currreport, skip, trigger, onaftergetrecord, control-flow]
technologies: [al]
countries: [w1]
application-area: [all]
---

# CurrReport.Skip omits the record but does not stop trigger code

## Description

`CurrReport.Skip()` omits the current record from the report dataset and continues processing with the next record. It does not terminate the current trigger, and the remaining triggers for the current record still run. Code placed after `Skip()` can therefore produce side effects for a record that never appears in the output.

## Best Practice

When no further code in the current trigger should run for a skipped record, call `CurrReport.Skip()` and then exit the trigger explicitly. Keep later record triggers safe for skipped records because the report runtime still invokes them.

See sample: [`currreport-skip-does-not-stop-trigger-code.good.al`](currreport-skip-does-not-stop-trigger-code.good.al).

## Anti Pattern

Call `CurrReport.Skip()` and rely on it to bypass subsequent statements or later record triggers. The record is removed from the dataset, but those statements and triggers can still update state, write data, or perform expensive work.

See sample: [`currreport-skip-does-not-stop-trigger-code.bad.al`](currreport-skip-does-not-stop-trigger-code.bad.al).

## References

`Report.Skip()` method — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/report/reportinstance-skip-method