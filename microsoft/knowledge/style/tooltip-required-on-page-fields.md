---
bc-version: [all]
domain: style
keywords: [tooltip, page-field, source-field, inheritance, aa0218, codecop, accessibility, specifies]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Page fields need an explicit or inherited `ToolTip` (CodeCop AA0218)

## Description

User-facing page fields need tooltip text, but it does not have to be declared on each page control. Starting with BC24 (2024 release wave 1), runtime 13.0 supports `ToolTip` on table fields, and bound page fields inherit it unless they override it. A non-empty inherited tooltip satisfies the requirement; do not interpret CodeCop AA0218 as a requirement to repeat it on the page.

For targets before runtime 13.0, table-field tooltip inheritance is not available, so user-facing page fields need page-level tooltips. Controls bound to variables or expressions also need page-level tooltips because they have no table field to inherit from. This is UI guidance, not a blanket requirement to add tooltips to every table field, including fields never exposed to users.

AA0218's severity is configured per app and may be downgraded or disabled. Review should still report a genuinely missing tooltip, but absence of a page-level declaration alone is not evidence of a gap. See [bound page-field tooltip inheritance](../ui/bound-page-field-inherits-source-field-tooltip.md).

## Best Practice

On runtime 13.0 or later, define shared tooltip text on the table field and omit duplicate page-level properties. Add a page-level `ToolTip` when no tooltip can be inherited or when the page needs different, context-specific help. Describe what the value shows, conventionally starting with "Specifies" or another clear phrasing.

Make the text answer a question the caption does not: what the value is used for, which values or units are expected, or what changing it affects. Do not mechanically generate "Specifies the <field name>." and consider the help complete. Use behavior established by the implementation or requirements; do not invent effects, defaults, or constraints to make a tooltip sound useful. Keep shared table-field help applicable to all pages that inherit it, and improve that shared text rather than duplicating it on each page.

Before raising a `medium`-severity finding, check the target runtime, the control's binding, and the source field's tooltip, including dependency symbols when needed. Report a field with neither an explicit nor an inherited tooltip independently of whether AA0218 is active. If the source definition or target runtime is unavailable, do not assume a missing page property means missing tooltip text.

See sample: [`tooltip-required-on-page-fields.good.al`](tooltip-required-on-page-fields.good.al) (BC24/runtime 13.0 or later).

## Anti Pattern

A user-facing control with no page-level `ToolTip` and no non-empty source tooltip it can inherit, or a page-level `ToolTip = '';` that leaves the effective tooltip empty.

Flagging a bound field that already inherits its tooltip, or adding the same tooltip to every page, is also incorrect: duplicate overrides add maintenance and translation work and prevent source-field tooltip changes from reaching those pages.

Treating a non-empty tooltip that merely repeats the caption as useful help is a separate quality issue, not a missing-tooltip finding. Point out the concrete information users need rather than demanding longer wording or a page-level override for its own sake.

See sample: [`tooltip-required-on-page-fields.bad.al`](tooltip-required-on-page-fields.bad.al).

## References

[ToolTip property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-tooltip-property).

[Guidelines for tooltip text](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/user-assistance#guidelines-for-tooltip-text).
