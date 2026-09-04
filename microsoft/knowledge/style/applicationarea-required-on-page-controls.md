---
bc-version: [all]
domain: style
keywords: [application-area, page-control, inheritance, as0062, appsourcecop, web-client]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Page-level `ApplicationArea` inheritance does not apply to extensions

## Description

A page control or action needs an effective `ApplicationArea` to appear in cloud experiences. From runtime 10.0, controls on a page object inherit the page-level value, so repeating it on every child is unnecessary when the parent defines a suitable default. This inheritance does not apply to controls added or modified by page and report extensions: extension controls must still set the property explicitly.

For targets before runtime 10.0, child controls do not inherit and must also set the property. AppSourceCop AS0062 and PTE0008 account for page-level inheritance on runtime 10.0 and later but continue to require explicit values in extensions.

## Best Practice

On runtime 10.0 or later, set a suitable page-level default and override only controls that belong to a narrower area. Set `ApplicationArea` explicitly on every control or action introduced by a page or report extension.

See sample: `applicationarea-required-on-page-controls.good.al`.

## Anti Pattern

A page object that defines neither a parent nor child value, or an extension control that assumes it inherits from the base page. The control has no effective application area and can be hidden or rejected by analyzer validation.

See sample: `applicationarea-required-on-page-controls.bad.al`.

## Reference

[Set different control properties](https://learn.microsoft.com/en-us/training/modules/work-with-pages/8-controls)
