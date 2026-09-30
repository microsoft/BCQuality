---
bc-version: [all]
domain: upgrade
keywords: [appversion, dataversion, moduleinfo, install-codeunit, upgrade-codeunit, version-context]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `ModuleInfo.AppVersion` changes meaning with execution context

## Description

`ModuleInfo.AppVersion()` is the installed version during normal operation, the version being installed inside install code, and the target version inside upgrade code. It is therefore not the source data version during an upgrade. In upgrade code, `DataVersion()` describes the version of the existing data, whether from the currently installed app or the version most recently uninstalled.

## Best Practice

Interpret `AppVersion()` as the code package entering the context and `DataVersion()` as the existing data state. Prefer upgrade tags for controlling individual migration steps; when version information is needed for diagnostics or preconditions, name variables so target app version and source data version cannot be confused.

## Anti Pattern

Reading `AppVersion()` from an upgrade codeunit and treating it as the version being upgraded from. The comparison actually observes the target package and can skip or misroute migration logic.

## Reference

[Create proper installation and upgrade codeunits](https://learn.microsoft.com/en-us/training/modules/easy-application-upgrade/3-installation-upgrade-codeunits)
