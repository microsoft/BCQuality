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

`CurrReport.Break()` inside a report dataitem trigger does more than leave an AL loop. It terminates the current trigger and omits the current record from the dataset, so statements after the loop in that trigger do not run.

In preserved BC 28.4.53241.57274-W1 processing-only `OnAfterGetRecord` results, it also ended the current dataitem's iteration: neither the next record nor the broken parent's children were processed, but `OnPostDataItem` and `OnPostReport` still ran. Some distinct record triggers can also run: a reportextension's `OnBeforeAfterGetRecord` calling `Break()` did not suppress the base `OnAfterGetRecord` or extension `OnAfterAfterGetRecord` in those results. This does not imply that every child or extension trigger runs.

## Best Practice

Use an explicit loop condition or the AL `break` statement when only the loop must end and the current trigger must continue. Do not use `CurrReport.Break()` as if it merely skipped one record while preserving later records of that dataitem; in the evidenced context it ends dataitem iteration as well.

Distinguish same-trigger statements from later base/extension triggers and dataitem/report completion. Require the actual trigger relationship and unsafe work before flagging later-trigger side effects. The documented current-trigger/AL-loop distinction is separate from the bounded BC 28.4 observations; do not infer an all-version helper-stack or XmlPort behavior matrix from them.

See sample: [`currreport-break-ends-the-current-trigger.good.al`](currreport-break-ends-the-current-trigger.good.al).

## Anti Pattern

Call `CurrReport.Break()` inside a loop and rely on statements after the loop to finish processing the current record. Those statements are not executed when the call ends the trigger. Conversely, assuming that ending this trigger suppresses all later distinct triggers is also unsafe.

See sample: [`currreport-break-ends-the-current-trigger.bad.al`](currreport-break-ends-the-current-trigger.bad.al).

## References

- [Report.Break() remarks and example](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/methods-auto/report/reportinstance-break-method), [pinned source](https://github.com/MicrosoftDocs/dynamics365smb-devitpro/blob/ad47532b59fa9acf932bae61920683796cb9dcf3/dev-itpro/developer/methods-auto/report/reportinstance-break-method.md#L31-L60): current-trigger termination, dataset omission, remaining triggers, and the difference from an AL `break`.
- [Documentation PR #5386](https://github.com/MicrosoftDocs/dynamics365smb-devitpro/pull/5386) deliberately added the remaining-trigger notes to both methods.
- Existing [BC 28.4 Windows-container run](https://github.com/aldevtools/BusinessCentral.AL.Language.Tests/actions/runs/41034608607), artifact `nightly-windows-bc28.4-41034608607`: externally supplied third-party-suite results on the Microsoft runtime, not a BCQuality execution or Microsoft-owned test suite. Pinned [direct-call assertions](https://github.com/aldevtools/BusinessCentral.AL.Language.Tests/blob/b8092fd0cf7d132d69fad00a8294554d5629946d/tests/al-language/report/lt-report-requestpage/RptSkipBreakQuit.al#L242-L249) and [extension-trigger assertions](https://github.com/aldevtools/BusinessCentral.AL.Language.Tests/blob/b8092fd0cf7d132d69fad00a8294554d5629946d/tests/al-language/errors/lt-ms-refusals-129/P129ReportExtBreak.al#L175-L194) establish the named contexts, not every trigger path or dataset row.
- Related [Skip clarification](currreport-skip-current-trigger-and-later-triggers.md); correction provenance: [PR #183 comment](https://github.com/microsoft/BCQuality/pull/183#issuecomment-6497847687) and [issue #200](https://github.com/microsoft/BCQuality/issues/200).