---
bc-version: [19..]
domain: reporting
keywords: [reportextension, report, dataitem, trigger-order, onbeforepredataitem, onafterpredataitem, onbeforeaftergetrecord, onafteraftergetrecord]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Choose ReportExtension dataitem triggers by their order around the base trigger

## Description

ReportExtension dataitem triggers run at defined points around the corresponding base-report trigger. `OnBeforePreDataItem` and `OnBeforeAfterGetRecord` run before the base trigger; `OnAfterPreDataItem` and `OnAfterAfterGetRecord` run after it. A filter or calculated value can be overwritten when an extension uses a before-trigger even though its result must be final after base processing.

## Best Practice

Choose the before or after trigger from the required ordering relative to base behavior. Use an after-trigger when the extension must observe or refine the final view or value produced by the base trigger. A before-trigger is valid when the base report must consume the extension's state.

See sample: [`reportextension-dataitem-trigger-order-is-explicit.good.al`](reportextension-dataitem-trigger-order-is-explicit.good.al).

## Anti Pattern

Place extension logic in a before-trigger while relying on its filter or value to survive a base trigger that can replace it. Do not report a before-trigger merely because an after-trigger exists; the defect requires visible base behavior or another reliable source showing that ordering changes the result.

See sample: [`reportextension-dataitem-trigger-order-is-explicit.bad.al`](reportextension-dataitem-trigger-order-is-explicit.bad.al).

## References

`OnBeforePreDataItem` report-extension trigger — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/triggers-auto/reportextensiondatasetmodify/devenv-onbeforepredataitem-reportextensiondatasetmodify-trigger

`OnAfterPreDataItem` report-extension trigger — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/triggers-auto/reportextensiondatasetmodify/devenv-onafterpredataitem-reportextensiondatasetmodify-trigger