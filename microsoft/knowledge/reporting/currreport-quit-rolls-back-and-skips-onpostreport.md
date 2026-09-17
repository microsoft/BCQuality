---
bc-version: [all]
domain: reporting
keywords: [report, currreport, quit, rollback, onpostreport, transaction, control-flow]
technologies: [al]
countries: [w1]
application-area: [all]
---

# CurrReport.Quit rolls back report changes and skips OnPostReport

## Description

`CurrReport.Quit()` aborts the report without committing database changes made during its execution. It also prevents `OnPostReport` from running. It is therefore not a normal early-return mechanism for a processing report that expects earlier writes or finalization in `OnPostReport` to survive.

## Best Practice

Use `CurrReport.Quit()` only when silently aborting the report, rolling back its database changes, and skipping `OnPostReport` are all intentional. When processing must stop with a failure, raise an error. When completed work and `OnPostReport` must be preserved, structure the dataitem control flow without `Quit()`.

See sample: [`currreport-quit-rolls-back-and-skips-onpostreport.good.al`](currreport-quit-rolls-back-and-skips-onpostreport.good.al).

## Anti Pattern

Modify data and then call `CurrReport.Quit()` while relying on those writes or on `OnPostReport` finalization. The report exits without committing its changes and never invokes `OnPostReport`.

See sample: [`currreport-quit-rolls-back-and-skips-onpostreport.bad.al`](currreport-quit-rolls-back-and-skips-onpostreport.bad.al).

## References

`Report.Quit()` method — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/report/reportinstance-quit-method