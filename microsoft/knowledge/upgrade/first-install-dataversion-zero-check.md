---
bc-version: [all]
domain: upgrade
keywords: [dataversion, first-install, on-install-app-per-company, moduleinfo, zero-version]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Detect first install with `DataVersion() = Version.Create('0.0.0.0')`

## Description

On the first install of an extension on a tenant the platform records a zero data version: `AppInfo.DataVersion()` returns `Version.Create('0.0.0.0')`. During reinstall, `DataVersion()` identifies the previously installed data version. The `OnInstallAppPerCompany` trigger uses this distinction to separate a brand-new install from a reinstall. Ordinary version upgrades do not run install code.

## Best Practice

In `OnInstallAppPerCompany`, fetch the current `ModuleInfo` via `NavApp.GetCurrentModuleInfo`, compare `AppInfo.DataVersion()` to `Version.Create('0.0.0.0')`, and run first-install seed logic only when they match. On a non-zero data version, follow the reinstall path or exit.

See sample: `first-install-dataversion-zero-check.good.al`.

## Anti Pattern

Treating `OnInstallAppPerCompany` as if it always implies "fresh tenant". The trigger also fires when reinstalling over an existing data set; without the `0.0.0.0` guard, first-install seed code can run again and duplicate rows.

See sample: `first-install-dataversion-zero-check.bad.al`.

## See also

- `use-upgrade-tags-not-version-checks.md` — for upgrade steps after first install, use upgrade tags rather than `DataVersion`.
- `install-code-does-not-run-on-version-upgrade.md` — ordinary version upgrades invoke upgrade code, not install code.
