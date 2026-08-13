---
bc-version: [all]
domain: upgrade
keywords: [upgrade-codeunit, subtype, on-upgrade-per-company, on-upgrade-per-database, trigger]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Upgrade logic must live in a codeunit with `Subtype = Upgrade`

## Description

A codeunit only participates in the upgrade pipeline when it sets `Subtype = Upgrade`. The platform then dispatches up to six system triggers on that codeunit during upgrade, run in this order:

| Trigger | Runs | Fails the upgrade on error |
|---|---|---|
| `OnCheckPreconditionsPerCompany` | once per company | Yes |
| `OnCheckPreconditionsPerDatabase` | once, no company open | Yes |
| `OnUpgradePerCompany` | once per company | Yes |
| `OnUpgradePerDatabase` | once, no company open | Yes |
| `OnValidateUpgradePerCompany` | once per company | Yes |
| `OnValidateUpgradePerDatabase` | once, no company open | Yes |

A codeunit without `Subtype = Upgrade` — even one that declares an `OnUpgradePerCompany` trigger — is not an upgrade codeunit, and reviewers ignore it for upgrade concerns. Conversely, any procedure invoked transitively from any of these six triggers on an upgrade codeunit IS upgrade code regardless of where it lives, and the upgrade rules apply to it.

Only `OnUpgradePerCompany`/`OnUpgradePerDatabase` do the actual data migration. `OnCheckPreconditions...` runs first and aborts the upgrade if a precondition isn't met; `OnValidateUpgrade...` runs last and aborts if the result can't be confirmed correct. See [[minimize-onvalidate-upgrade-triggers]] for CURABIS's own guidance on when to use the CheckPreconditions/ValidateUpgrade pair versus keeping upgrade logic in `OnUpgrade...` alone.

## Best Practice

Place every piece of upgrade logic in a codeunit declared with `Subtype = Upgrade;` and expose entry points via whichever of the six triggers the scenario needs — at minimum `OnUpgradePerCompany`/`OnUpgradePerDatabase`, optionally paired with `OnCheckPreconditions...`/`OnValidateUpgrade...`. Helper procedures may live in normal codeunits, but they inherit the upgrade-context rules (guarded reads, no external calls, upgrade tags, etc.) when called from any of these six triggers.

See sample: `upgrade-codeunit-subtype.good.al`.

## Anti Pattern

Putting upgrade-style logic in a regular codeunit that the platform never invokes during upgrade — for example a normal codeunit with a manually invented "RunUpgrade" procedure that nothing wires to the upgrade pipeline. The migration code will simply not run.

See sample: `upgrade-codeunit-subtype.bad.al`.
