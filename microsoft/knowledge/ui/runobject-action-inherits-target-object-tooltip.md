---
bc-version: [26..]
domain: ui
keywords: [tooltip, action, runobject, role-center, object-level, inheritance, caption, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A `RunObject` action inherits the targeted object's `ToolTip`

## Description

Since BC 2025 release wave 1, an action on a role center that specifies `RunObject` uses the `Caption`, `ToolTip`, `AboutText`, and `AboutTitle` of the targeted application object when the action itself declares none of them; a property set on the action overrides the inherited value. Where object-level tooltip text can live has since widened: `ToolTip`/`ToolTipML` became available on report objects in BC 2026 release wave 1 (runtime 17.0) and on page objects in BC 2026 release wave 2 (runtime 18.0). A navigation action with `RunObject = page X` inherits page X's object-level `ToolTip` when the action declares none of its own. An action without an inline `ToolTip` is therefore not, by itself, a missing-tooltip defect when the object it runs supplies the text.

## Best Practice

Define the tooltip on the targeted object where the platform supports it and let `RunObject` actions inherit it; set `ToolTip` on the action only when its context genuinely needs different wording. For page fields, the analogous source is the bound table field — see `bound-page-field-inherits-source-field-tooltip.md`.

## Anti Pattern

Flagging every `RunObject` action that declares no inline `ToolTip` as a missing-tooltip violation, ignoring that the action inherits the targeted object's text at runtime on BC 26 and later.
