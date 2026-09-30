---
bc-version: [all]
domain: reporting
keywords: [report, currreport, break, loop, trigger, control-flow]
technologies: [al]
countries: [w1]
application-area: [all]
---

# CurrReport.Break ends the current trigger

## Description

`CurrReport.Break()` inside a report dataitem trigger does more than leave an AL loop. It terminates the current trigger and omits the current record from the dataset. The report runtime still invokes the remaining triggers for that record. Consequently, statements after the loop in the current trigger do not run, while later report triggers can still produce side effects.

## Best Practice

Use an explicit loop condition or the AL `break` statement when only the loop must end and the current trigger must continue. Use `CurrReport.Break()` only when ending the trigger and omitting the current record are both intended, and keep subsequent report triggers safe for that omitted record.

See sample: [`currreport-break-ends-the-current-trigger.good.al`](currreport-break-ends-the-current-trigger.good.al).

## Anti Pattern

Call `CurrReport.Break()` inside a loop and rely on statements after the loop to finish processing the current record. Those statements are unreachable when the call executes, the record is omitted, and remaining report triggers still run.

See sample: [`currreport-break-ends-the-current-trigger.bad.al`](currreport-break-ends-the-current-trigger.bad.al).

## References

`Report.Break()` method — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/report/reportinstance-break-method