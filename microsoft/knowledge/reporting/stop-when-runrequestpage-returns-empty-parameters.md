---
bc-version: [all]
domain: reporting
keywords: [report, runrequestpage, cancel, parameters, saveas, execute, print]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Stop when RunRequestPage returns empty parameters

## Description

`Report.RunRequestPage()` returns an empty string when the user chooses **Cancel**. Passing that value to `Report.Execute`, `Report.Print`, or `Report.SaveAs` ignores the cancellation and can run the report with default parameters instead.

## Best Practice

Test the returned parameter string immediately after `RunRequestPage()` and exit when it is empty. Pass the value to `Execute`, `Print`, or `SaveAs` only after the user has confirmed the request page.

See sample: [`stop-when-runrequestpage-returns-empty-parameters.good.al`](stop-when-runrequestpage-returns-empty-parameters.good.al).

## Anti Pattern

Call `RunRequestPage()` and unconditionally pass its return value to a report execution method. Choosing **Cancel** can still execute, print, or save the report.

See sample: [`stop-when-runrequestpage-returns-empty-parameters.bad.al`](stop-when-runrequestpage-returns-empty-parameters.bad.al).

## References

`Report.RunRequestPage()` method — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/report/report-runrequestpage-method