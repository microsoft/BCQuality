---
bc-version: [all]
domain: ui
keywords: [tooltip, page-field, source-field, inheritance, aa0218, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A page field bound to a table field inherits that field's ToolTip

## Description

A page field bound to a table field inherits the source field's `ToolTip` at runtime: the control shows the table field's `ToolTip` even when the page control declares none of its own. A page field without an inline `ToolTip` is therefore not, by itself, a missing-tooltip defect — the text may be supplied by the bound source field.

The genuinely-missing case — a bound field whose source table field also carries no `ToolTip`, or an unbound control that needs one — is already reported by the compiler analyzer AA0218, which BCQuality calibrates to `info`. That analyzer, not an agent finding, owns the missing-tooltip signal.

## Best Practice

Do not raise a missing-`ToolTip` finding for a page field that has a source-table binding; assume the source field supplies the tooltip. Reserve tooltip findings for the cases the dedicated tooltip rules define, and let analyzer AA0218 carry the mechanically-detectable missing-tooltip case at its calibrated severity.

## Anti Pattern

Flagging every page field that has no inline `ToolTip` property as an accessibility violation, ignoring that a bound field inherits its source field's tooltip and that AA0218 already covers the truly-missing case.
