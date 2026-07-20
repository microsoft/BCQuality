---
bc-version: [all]
domain: style
keywords: [tooltip, page-field, table-field, aa0218, aa0234, codecop, accessibility, inheritance, specifies]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Every page field needs a `ToolTip` — inline or inherited from the source table field (CodeCop AA0218/AA0234)

## Description

Every field control on a page must present a non-empty tooltip: it is what users see on hover and what screen readers announce, and AppSource technical validation rejects pages without it. The tooltip does not have to be declared on the page control. Since BC 2024 release wave 1 (BC 24, runtime 13.0), table fields carry a `ToolTip` property, a bound page field inherits its source field's tooltip at runtime, and a page-level `ToolTip` acts only as a contextual override. CodeCop AA0234 recommends writing tooltips on table fields, and AA0218 — the rule requiring a tooltip on every page field and action — takes source-field tooltips into account, so it does not fire on a bound page field whose table field defines the text.

The companion rules AA0219 and AA0220 push the wording further — tooltips should describe what the field shows, conventionally starting with `'Specifies …'`, though `'Shows …'` and similar variants are acceptable when they clearly describe the field's purpose.

Acceptable exceptions: table fields inside `Upgrade`, `Migration`, `HybridBC14`, `HybridSL`, and `HybridGP` codeunits and tables are allowed to omit the tooltip — those types are not surfaced to users.

## Best Practice

Every field control on a regular page carries `ToolTip = 'Specifies …';` (or a clear alternative phrasing). Compose the text in the form "what this value shows" rather than "what the user does with it". The inline property may be omitted when the source already defines the text: the bound table field (BC 24 and later — the preferred single place, per AA0234) or, for `RunObject` actions, the targeted object (see `../ui/runobject-action-inherits-target-object-tooltip.md`).

See sample: `tooltip-required-on-page-fields.good.al`.

## Anti Pattern

A field whose tooltip exists nowhere — the source table field declares no `ToolTip` and the page control declares none either — or a control with `ToolTip = '';`. The hover state is blank and the screen reader has nothing to announce; AA0218 flags exactly these cases.

Equally wrong in review: demanding an inline `ToolTip` on a bound page field whose source table field already defines one. The control inherits the table text at runtime; requiring a duplicate on the page is a false positive and reintroduces the pre-BC24 duplication that AA0234 exists to remove (see `../ui/bound-page-field-inherits-source-field-tooltip.md`).

See sample: `tooltip-required-on-page-fields.bad.al`.
