---
bc-version: [all]
domain: upgrade
keywords: [contoso-demo-data-module, demo-tool, demo-data, upgrade-codeunit, preview, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Contoso demo-data seeding does not need an upgrade codeunit

## Description

Codeunits that `implements "Contoso Demo Data Module"` (the Contoso demo-data-tool
interface, e.g. `CreateSetupData`, `CreateMasterData`, `CreateTransactionalData`,
`CreateHistoricalData`) are only ever invoked on demand by the demo data tool when a
user explicitly chooses to generate or refresh Contoso demo data. They are not part of
the extension's install/upgrade lifecycle: the platform never calls them automatically,
and no already-provisioned tenant silently receives their records on extension
upgrade — the user must rerun the demo tool to get new or changed Contoso records, for
every change in that data, not just this one. Adding new seeding steps (for example a
new reference/rate table population) inside `CreateMasterData`/`CreateSetupData` of
such a module is consistent with every other Contoso demo-data change and does not
leave real tenant data stale. The `upgrade-codeunit-subtype` and
`install-code-does-not-run-on-version-upgrade` rules govern code that must run against
real, already-provisioned tenant data; they do not apply to Contoso demo/preview data
generation.

## Best Practice

Do not require `Subtype = Upgrade` wiring, `OnUpgradePerCompany`/`OnUpgradePerDatabase`
entry points, or an upgrade codeunit for new seeding logic added to a codeunit that
implements `"Contoso Demo Data Module"` and is only reached through
`CreateSetupData`/`CreateMasterData`/`CreateTransactionalData`/`CreateHistoricalData`.
Flag missing upgrade wiring only when the changed code also runs for real tenants
outside the demo tool's on-demand generation flow.
