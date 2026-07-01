---
bc-version: [all]
domain: style
keywords: [application-area, page-control, as0062, appsourcecop, hidden-control, web-client]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Every page control needs an `ApplicationArea` (AppSourceCop AS0062)

## Description

A field control on a page or pageextension that has no `ApplicationArea` property is silently hidden in the Web client for every profile whose enabled application areas do not cover it. There is no error and no warning at runtime — the field simply does not appear, which reads as data loss to the user. AppSourceCop AS0062 flags any page control or action that is missing the `ApplicationArea` property, and AppSource technical validation rejects the app until it is set.

Set the property to an area the app actually enables. `All` makes the control visible under every profile and is the common default; if the app declares narrower areas in `app.json`, use one of those. The property applies to field controls and to actions. This is a sibling concern to `caption-required-on-page-fields.md` and `tooltip-required-on-page-fields.md`; note that the ToolTip requirement is the separate CodeCop rule AA0218, not AS0062.

## Best Practice

Every field control and action carries `ApplicationArea = All;` (or a declared area of the app). The value is set once per control and keeps the control visible in the Web client.

See sample: `applicationarea-required-on-page-controls.good.al`.

## Anti Pattern

A field control with no `ApplicationArea`. AS0062 flags it, and the control is invisible in the Web client for any profile that does not already enable a matching area.

See sample: `applicationarea-required-on-page-controls.bad.al`.
