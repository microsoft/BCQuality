---
bc-version: [all]
domain: upgrade
keywords: [oninstall, dataversion, appinfo, first-install, upgrade-tag]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Detect first install via DataVersion equal to 0.0.0.0 in OnInstall triggers

## Description

`OnInstallAppPerCompany` fires on first install and on subsequent re-installs after an uninstall. Code that should only run on the very first install needs to distinguish the two — and the supported way is checking `AppInfo.DataVersion() = Version.Create('0.0.0.0')`, which is the sentinel for "no prior data exists for this app in this tenant". This is the one case where a DataVersion check is correct; steady-state upgrade steps should use upgrade tags instead.

## Best Practice

In `OnInstallAppPerCompany`, call `NavApp.GetCurrentModuleInfo(AppInfo)` and exit early when `AppInfo.DataVersion()` is non-zero. The remainder of the trigger body then runs exclusively on first install. For all other version-sensitive upgrade logic, use upgrade tags (see `use-upgrade-tags-not-version-checks`).

See sample: `detect-first-install-via-dataversion-zero.good.al`.

## Anti Pattern

Running initialization unconditionally in `OnInstallAppPerCompany` and relying on primary-key collisions to avoid double-inserts. Re-install scenarios either throw or overwrite existing rows; the install path becomes brittle as the app grows.

See sample: `detect-first-install-via-dataversion-zero.bad.al`.
