---
bc-version: [all]
domain: appsource
keywords: [usagecategory, tell-me, search, page, report, discoverability]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set UsageCategory on searchable entry points

## Description

Pages and reports that users are expected to open directly must set `UsageCategory`. Without it, the object is absent from Tell Me and users cannot bookmark it from the web client. Supporting objects such as list parts, dialogs, API pages, and objects reached only through another page do not need to be searchable entry points.

## Best Practice

Set `UsageCategory` to the category that matches the entry point, such as `Lists`, `Tasks`, `ReportsAndAnalysis`, or `Documents`. Also set the appropriate object-level `ApplicationArea` so search results respect feature visibility.

See sample: `set-usagecategory-on-searchable-entry-points.good.al`.

## Anti Pattern

A user-facing page or report intended for direct discovery omits `UsageCategory` or sets it to `None`. Do not infer intent from the object type alone; require evidence that the object is a direct user entry point.

See sample: `set-usagecategory-on-searchable-entry-points.bad.al`.