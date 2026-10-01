---
bc-version: [all]
domain: upgrade
keywords: [demo-data, contoso, preview, setup, false-positive, upgrade-codeunit]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Contoso/demo-data seeding needs no upgrade codeunit

## Description

Demo-data generators (for example Contoso module codeunits invoked from a
setup/demo-data-creation entry point) are not part of the tenant-upgrade
pipeline. They populate sample records for a demo, preview, or trial company
on explicit, manual invocation of the demo-data tool — they do not run
automatically for already-provisioned tenants the way `OnUpgradePerCompany`
or `OnUpgradePerDatabase` do, and they are not expected to. Wiring a new demo
record set only into the existing `CreateMasterData`-style entry point is
correct; it is not a missing upgrade path, because there is no real tenant
data to backfill.

## Best Practice

Keep demo/Contoso seeding codeunits (`Codeunit.Run` chains invoked from demo
data creation, e.g. `CreateMasterData`) wired only into the demo-data
generation flow. Do not require an `Subtype = Upgrade` codeunit or
`OnUpgradePerCompany`/`OnUpgradePerDatabase` trigger for this kind of seeding;
the data is regenerated on demand, not migrated for existing tenants.

## Anti Pattern

Flagging a new demo/Contoso data-seeding step (e.g. a VAT-rate seeding
codeunit run from `CreateMasterData`) as missing an upgrade entry point on
the theory that previously provisioned tenants will not receive it on
upgrade. Demo-data modules are not upgraded; they are re-run by the demo
tool.
