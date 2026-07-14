---
bc-version: [all]
domain: upgrade
keywords: [on-check-preconditions, on-validate-upgrade, on-upgrade, read-only-check, data-migration]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Upgrade check triggers do not migrate data

## Description

`OnCheckPreconditionsPerCompany`/`PerDatabase` run before the upgrade to verify that it can start. `OnValidateUpgradePerCompany`/`PerDatabase` run after upgrade logic to verify that it succeeded. Treat both phases as read-only checks. The `OnUpgradePerCompany`/`PerDatabase` phase is where the platform expects actual data transformation.

## Best Practice

Have check triggers call query-only helpers that raise an error when an invariant fails. Put every `Insert`, `Modify`, `Delete`, `Rename`, `DataTransfer`, and other migration write behind helpers called from the matching `OnUpgrade...` trigger.

See sample: `check-only-triggers-do-not-migrate-data.good.al`.

## Anti Pattern

Repairing data in `OnCheckPreconditions...` or finishing migration in `OnValidateUpgrade...`. Those writes blur the phase contract and make a check alter the state it is supposed to assess.

See sample: `check-only-triggers-do-not-migrate-data.bad.al`.
