---
bc-version: [24..]
domain: ui
keywords: [tooltip, page-field, source-field, inheritance, aa0218, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A page field bound to a table field inherits that field's ToolTip

## Description

Starting with BC24 (2024 release wave 1), runtime 13.0 supports `ToolTip` on table fields. A page field bound to a table field inherits the source field's `ToolTip` when the page control declares none of its own. A page field without an inline `ToolTip` is therefore not, by itself, a missing-tooltip defect. This inheritance is not available when targeting earlier runtimes.

The genuinely-missing case is different: a control with no inline `ToolTip` also has no text to inherit when it is unbound or its source table field carries no non-empty `ToolTip`. This leaves a real user-assistance gap. The compiler analyzer AA0218 detects this mechanically, but its severity is set by each app's ruleset and may be downgraded or disabled, so review should raise the genuine gap independently.

## Best Practice

Check the target runtime and inspect the source field, including dependency symbols when needed. On runtime 13.0 or later, do not raise a missing-`ToolTip` finding for a bound page field whose source table field supplies a non-empty `ToolTip`, and do not add a duplicate page-level property. A page-level override is appropriate only when the page needs different help text or no tooltip can be inherited.

Do raise a `medium`-severity finding when the field has no inline `ToolTip` **and** no inherited one, rather than assuming AA0218 will catch it downstream. If the source definition is unavailable, do not infer that its tooltip is missing. See [tooltip requirements across target versions](../style/tooltip-required-on-page-fields.md).

## Anti Pattern

Two opposite failures: (1) flagging every page field that has no inline `ToolTip` as a violation, ignoring that a bound field inherits its source field's tooltip; and (2) staying silent on a field that has neither an inline nor an inherited tooltip on the assumption that the compiler's AA0218 will report it — a ruleset that downgrades or disables AA0218 then lets a genuine gap ship unflagged.

## References

[ToolTip property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-tooltip-property).
