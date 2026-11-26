---
bc-version: [all]
domain: reporting
keywords: [report, currreport, skip, trigger, onaftergetrecord, reportextension, control-flow, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# CurrReport.Skip: separate current-trigger exit from later triggers

## Description

`CurrReport.Skip()` omits the current record from the report dataset. In preserved BC 28.4.53241.57274-W1 processing-only report results, a direct call in `OnAfterGetRecord` ended that trigger: statements after the call did not execute, the skipped parent's child dataitem was not traversed, and processing continued with the next record.

This is different from the documented statement that remaining triggers are still called. For example, `Skip()` in a reportextension's `OnBeforeAfterGetRecord` does not necessarily suppress the base `OnAfterGetRecord` or the extension's `OnAfterAfterGetRecord`. Dataitem/report completion in `OnPostDataItem` and `OnPostReport` is another distinct stage, not a trigger invocation for each skipped record.

## Best Practice

Do not flag statements following a direct `Skip()` in the evidenced `OnAfterGetRecord` context as side effects that still execute for the skipped record, or require an extra `exit;` solely to prevent that alleged continuation. The clarification prevents an incorrect finding; it does not establish identical control flow across every version, helper-procedure stack, reportextension call site, or XmlPort.

When reviewing later distinct triggers, require the visible call site, trigger relationship, and unsafe skipped-record work before reporting a defect. Do not equate omission from the dataset with suppression of all later base/extension triggers, or interpret "remaining triggers" as a guarantee that every child dataitem is traversed.

## Anti Pattern

Claiming that an increment after a direct `Skip()` must run for the skipped record, automatically adding `exit;` to fix it, or making the opposite blanket claim that no later distinct trigger can run. Same-trigger reachability, later-trigger dispatch, next-record processing, child traversal, and dataset emission are separate questions.

## References

- [Report.Skip() remarks](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/report/reportinstance-skip-method), [pinned source](https://github.com/MicrosoftDocs/dynamics365smb-devitpro/blob/ad47532b59fa9acf932bae61920683796cb9dcf3/dev-itpro/developer/methods-auto/report/reportinstance-skip-method.md#L31-L51): dataset omission and remaining triggers; not an explicit same-trigger continuation guarantee.
- [Microsoft's by-design explanation for reportextension Skip](https://github.com/microsoft/AL/issues/7039#issuecomment-2270209224).
- Existing [BC 28.4 Windows-container run](https://github.com/aldevtools/BusinessCentral.AL.Language.Tests/actions/runs/41034608607), artifact `nightly-windows-bc28.4-41034608607`: externally supplied results from a third-party suite on the Microsoft runtime, not a BCQuality execution or Microsoft-owned test suite. Its pinned [direct-call source](https://github.com/aldevtools/BusinessCentral.AL.Language.Tests/blob/b8092fd0cf7d132d69fad00a8294554d5629946d/tests/al-language/report/lt-report-requestpage/RptSkipBreakQuit.al#L88-L105), [direct-call assertions](https://github.com/aldevtools/BusinessCentral.AL.Language.Tests/blob/b8092fd0cf7d132d69fad00a8294554d5629946d/tests/al-language/report/lt-report-requestpage/RptSkipBreakQuit.al#L230-L249), and [extension-trigger assertions](https://github.com/aldevtools/BusinessCentral.AL.Language.Tests/blob/b8092fd0cf7d132d69fad00a8294554d5629946d/tests/al-language/errors/lt-ms-refusals-129/P129ReportExtBreak.al#L175-L194) distinguish same-trigger statements from record progression and later dispatch. Processing-only traces do not themselves prove dataset emission.
- Correction provenance: [issue #200](https://github.com/microsoft/BCQuality/issues/200) and [PR #183 comment](https://github.com/microsoft/BCQuality/pull/183#issuecomment-6497847687).