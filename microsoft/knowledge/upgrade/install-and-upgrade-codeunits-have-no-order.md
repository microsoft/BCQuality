---
bc-version: [all]
domain: upgrade
keywords: [install-codeunit, upgrade-codeunit, execution-order, subtype-install, subtype-upgrade, sequencing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Separate install or upgrade codeunits have no execution order

## Description

An extension can contain multiple `Install` or `Upgrade` codeunits, but Business Central does not guarantee the order in which codeunits of the same subtype execute. Upgrade trigger phases are ordered globally, yet one codeunit's `OnUpgradePerCompany` must not assume another codeunit's same-phase trigger already ran. Object ID and source-file order do not provide sequencing.

## Best Practice

Keep separate install or upgrade codeunits independent. When two steps have a real dependency, coordinate them from one owning trigger in the required order; use upgrade tags to make each completed step idempotent.

See sample: `install-and-upgrade-codeunits-have-no-order.good.al`.

## Anti Pattern

Splitting dependent steps into separate codeunits and relying on names, object IDs, or declaration order. The dependent codeunit can run first and fail or observe partially migrated data.

See sample: `install-and-upgrade-codeunits-have-no-order.bad.al`.

## Reference

[Create proper installation and upgrade codeunits](https://learn.microsoft.com/en-us/training/modules/easy-application-upgrade/3-installation-upgrade-codeunits)
