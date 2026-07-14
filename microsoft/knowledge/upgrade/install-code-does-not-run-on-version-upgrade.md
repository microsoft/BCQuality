---
bc-version: [all]
domain: upgrade
keywords: [install-codeunit, subtype-install, on-install-app, version-upgrade, upgrade-codeunit]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Install code does not run during a version upgrade

## Description

An install codeunit runs when an extension is installed for the first time or an uninstalled version is installed again. Installing a higher extension version through the data-upgrade operation does not invoke `OnInstallAppPerCompany` or `OnInstallAppPerDatabase`. Ordinary version-to-version migration is dispatched only through upgrade codeunits.

## Best Practice

Use `Subtype = Install` for first-install and reinstall initialization. Put version migration in a separate `Subtype = Upgrade` codeunit and enter it from `OnUpgradePerCompany` or `OnUpgradePerDatabase`.

See sample: `install-code-does-not-run-on-version-upgrade.good.al`.

## Anti Pattern

Putting a schema or data migration only in an install trigger and expecting it to run when a higher app version is upgraded. The migration is never invoked on that path.

See sample: `install-code-does-not-run-on-version-upgrade.bad.al`.
