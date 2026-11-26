---
bc-version: [20..]
domain: reporting
keywords: [rendering, defaultrenderinglayout, defaultlayout, rdlclayout, wordlayout, excellayout, layoutfile, legacy-layout]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Declare report layouts in the rendering section, not with the legacy layout properties

## Description

Since runtime 9.0 (BC20), reports declare layouts in a `rendering` section of named `layout` entries, each with `Type`, `LayoutFile`, `Caption`, and `Summary`, and choose the default by name with `DefaultRenderingLayout`. The older properties `DefaultLayout`, `RDLCLayout`, `WordLayout`, and `ExcelLayout` allow only one layout per type, select the default by type, and Microsoft documents that they should be avoided because they will be deprecated. Code that reads them also loads the full layout into memory even when it only checks whether a layout of that type exists.

Agents still produce the legacy properties because most published samples and older Base Application code use them.

## Best Practice

In new or changed reports, declare every layout in `rendering`, set `DefaultRenderingLayout` on the report, and give each layout a `Caption` and `Summary` so users can choose between them on the **Report Layouts** page. When touching a report that still uses the legacy properties, convert it with the AL code action **Convert to 'Rendering'**.

See sample: [`declare-report-layouts-in-the-rendering-section.good.al`](declare-report-layouts-in-the-rendering-section.good.al).

## Anti Pattern

A new report, or a changed report's layout declaration, that uses `DefaultLayout` together with `RDLCLayout`, `WordLayout`, or `ExcelLayout`.

Do not flag unchanged legacy declarations in code outside the review scope, or projects whose target runtime is below 9.0.

See sample: [`declare-report-layouts-in-the-rendering-section.bad.al`](declare-report-layouts-in-the-rendering-section.bad.al).

## References

[DefaultLayout property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-defaultlayout-property) (avoid the legacy properties; they will be deprecated; reading them loads the full layout), [Declare report layouts in AL](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-report-layout-declaration), and [Defining multiple report layouts](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-multiple-report-layouts).
