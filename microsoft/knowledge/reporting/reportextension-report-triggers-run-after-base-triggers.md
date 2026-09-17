---
bc-version: [18..]
domain: reporting
keywords: [reportextension, report, trigger-order, onprereport, onpostreport, base-report, integration-event]
technologies: [al]
countries: [w1]
application-area: [all]
---

# ReportExtension report triggers run after base report triggers

## Description

`OnPreReport` and `OnPostReport` on a ReportExtension run after the corresponding triggers on the base report. An extension `OnPreReport` cannot prepare state that the base `OnPreReport` must consume, and an extension `OnPostReport` cannot affect finalization that the base `OnPostReport` has already completed.

## Best Practice

Use a base-report event at the required execution point when extension logic must run before or within a base trigger. Use ReportExtension `OnPreReport` and `OnPostReport` only for work that is correct after the corresponding base trigger. Report a violation only when the base trigger and extension dependency are both visible or otherwise established.

See sample: [`reportextension-report-triggers-run-after-base-triggers.good.al`](reportextension-report-triggers-run-after-base-triggers.good.al).

## Anti Pattern

Initialize data in a ReportExtension `OnPreReport` and rely on the base report's `OnPreReport` to consume it, or perform extension `OnPostReport` work that the base `OnPostReport` needed beforehand. The base trigger has already run.

See sample: [`reportextension-report-triggers-run-after-base-triggers.bad.al`](reportextension-report-triggers-run-after-base-triggers.bad.al).

## References

Report extension object — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-report-ext-object