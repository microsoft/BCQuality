---
bc-version: [all]
domain: upgrade
keywords: [changecompany, cross-company, onupgradepercompany, onupgradeperdatabase, feature-data-update, taskscheduler, multi-company, company-context]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Upgrade code must not use ChangeCompany

## Description

The platform upgrades each company in its own context: `OnUpgradePerCompany` (like the other `PerCompany` upgrade and install triggers) runs once per company, in a separate system session opened for that company, while `PerDatabase` triggers run in a session that opens no company. Calling `ChangeCompany(<name>)` in upgrade code reaches from the company being upgraded into another company. Cross-company work bypasses the platform's per-company execution boundary, making execution order and migration ownership difficult to reason about and potentially repeating work. A cross-company read cannot assume that the other company's migration has already run, so it can observe pre-upgrade or post-upgrade data. Per-company upgrade tags are set for the current company only, so a tag set after writing to company B is recorded for company A, which can cause B's own session to repeat the migration. Execution context does not move with `ChangeCompany`: table triggers and trigger-event subscribers still run in the calling company (see `changecompany-runs-triggers-in-the-calling-company`). Data and side effects then land in different companies, and an error in another company's data aborts the current company's upgrade. The same applies to the migration path of a feature-switch data update: the `UpdateData` and `AfterUpdate` methods of a `Feature Data Update` implementation. Feature Management runs them for one company's status row, either as a task scheduled in that company or in the current session. The interface's preflight methods, `IsDataUpdateRequired` and `ReviewData`, are a separate phase that reports scope before any update is scheduled.

## Best Practice

Upgrade code operates only on the company it is running in. Put per-company data migration in `OnUpgradePerCompany` (or a helper reachable only from it), guard it with a per-company upgrade tag, and let the platform invoke it for every company. Reserve `OnUpgradePerDatabase` for tables with `DataPerCompany = false` and other database-wide state; it needs no `ChangeCompany`. A feature data update implements `UpdateData` and `AfterUpdate` against the current company only. Its read-only preflight may use `ChangeCompany` to count or inspect rows in other companies, because it migrates nothing. When code outside the upgrade pipeline must start work in other companies, schedule it in each company with `TaskScheduler.CreateTask` and the company name, as Feature Management does, rather than writing there through `ChangeCompany`. The scheduled task runs in the target company, so triggers, events, permissions, and upgrade tags all use that company.

See sample: [`no-changecompany-in-upgrade.good.al`](no-changecompany-in-upgrade.good.al).

## Anti Pattern

A loop over the `Company` table in `OnUpgradePerDatabase` or `OnUpgradePerCompany` that calls `ChangeCompany(Company.Name)` on a record or `RecordRef` and then reads, inserts, modifies, or deletes data. Another form is a `Feature Data Update` implementation whose `UpdateData` or `AfterUpdate` does the same to update every company from one task. On these paths reads are not exempt: they observe another company whose upgrade state is unknown.

Detection signal: `Record.ChangeCompany(<name>)` or `RecordRef.ChangeCompany(<name>)` with a company-name argument in a codeunit with `Subtype = Upgrade` or in any procedure transitively reachable from its upgrade triggers, or in a `Feature Data Update` implementation's `UpdateData` or `AfterUpdate` or any procedure transitively reachable from them. Do not flag `ChangeCompany` in `IsDataUpdateRequired`, `ReviewData`, or helpers reachable only from them; a helper shared with `UpdateData` or `AfterUpdate` is in scope. Do not flag the parameterless `ChangeCompany()`, which only points the variable back at the current company, or `ChangeCompany` in ordinary runtime code; `changecompany-runs-triggers-in-the-calling-company` governs that.

See sample: [`no-changecompany-in-upgrade.bad.al`](no-changecompany-in-upgrade.bad.al).

## References

- Upgrading extensions, Upgrade triggers: `PerCompany` triggers run once per company, each in its own system session for that company — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-upgrading-extensions
- Record.ChangeCompany method, Remarks: triggers still run in the current company — https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-changecompany-method
- Interface "Feature Data Update" — https://learn.microsoft.com/en-us/dynamics365/business-central/application/system-application/interface/system.environment.configuration.feature-data-update
- `FeatureManagementImpl.UpdateData` calls the interface's `UpdateData` then `AfterUpdate`; `ReviewData` calls `IsDataUpdateRequired` and `ReviewData` — https://github.com/microsoft/BCApps/blob/main/src/System%20Application/App/Feature%20Key/src/FeatureManagementImpl.Codeunit.al
- `FeatureManagementImpl.CreateTask` schedules `Update Feature Data` with `TaskScheduler.CreateTask` for the status row's company — https://github.com/microsoft/BCApps/blob/main/src/System%20Application/App/Feature%20Key/src/FeatureManagementImpl.Codeunit.al
