---
bc-version: [all]
domain: upgrade
keywords: [upgrade-codeunit, onupgradepercompany, onupgradeperdatabase, structure]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Call named methods from OnUpgrade triggers; keep the triggers empty of logic

## Description

An upgrade codeunit (`Subtype = Upgrade`) runs its triggers once per upgrade scope. Inlining upgrade logic inside the trigger body mixes the entry point with the work, makes individual steps untestable in isolation, and prevents the standard upgrade-tag guard pattern from being applied cleanly. The convention across Business Central's own upgrade codeunits is that `OnUpgradePerCompany` and `OnUpgradePerDatabase` are a list of calls to named local procedures, each implementing one step behind its own upgrade-tag check.

## Best Practice

Keep `OnUpgradePerCompany` and `OnUpgradePerDatabase` to a list of `UpgradeXxx();` statements. Put every data migration, default, or correction in a named local procedure whose first action is the upgrade-tag guard. Empty trigger bodies are also acceptable as placeholders on a new codeunit with no current steps.

See sample: `call-methods-from-onupgrade-triggers-not-inline-code.good.al`.

## Anti Pattern

Writing `Customer.ModifyAll(...)`, `TableX.SetRange(...)` + loops, or `DataTransfer.CopyFields()` directly inside the trigger body. The step is untagged, untestable, and re-runs on every upgrade.

See sample: `call-methods-from-onupgrade-triggers-not-inline-code.bad.al`.
