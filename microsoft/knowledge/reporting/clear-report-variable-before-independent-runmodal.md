---
bc-version: [all]
domain: reporting
keywords: [report, runmodal, clear, settableview, instance, state, filters]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Clear a Report variable before an independent RunModal execution

## Description

`Report.Run()` automatically clears the report variable after execution, but `Report.RunModal()` does not. Reconfiguring and running the same variable for an independent operation can therefore retain filters and other instance state from the previous run.

## Best Practice

Call `Clear(ReportVariable)` before configuring a new, logically independent `RunModal()` execution on a reused report variable. No clear is required after a single execution, and retaining state is valid when the subsequent run intentionally continues with the same configuration.

See sample: [`clear-report-variable-before-independent-runmodal.good.al`](clear-report-variable-before-independent-runmodal.good.al).

## Anti Pattern

Run the same report variable modally for two independent views without clearing it between runs. The second `SetTableView` can only narrow the existing report view, so filters retained by the instance can make the second result incomplete or empty.

See sample: [`clear-report-variable-before-independent-runmodal.bad.al`](clear-report-variable-before-independent-runmodal.bad.al).

## References

`Report.RunModal()` method — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/report/reportinstance-runmodal-method

`Report.Run()` method — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/report/reportinstance-run-method