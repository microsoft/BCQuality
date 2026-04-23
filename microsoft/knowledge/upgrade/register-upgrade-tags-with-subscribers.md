---
bc-version: [all]
domain: upgrade
keywords: [upgrade-tag, ongetpercompanyupgradetags, ongetperdatabaseupgradetags, registration]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Register every upgrade tag with the matching PerCompany or PerDatabase subscriber

## Description

An upgrade tag set via `UpgradeTag.SetUpgradeTag` only participates in the platform's upgrade-tag machinery when it is also registered through `OnGetPerCompanyUpgradeTags` or `OnGetPerDatabaseUpgradeTags` event subscribers on `Codeunit "Upgrade Tag"`. Without registration, the platform cannot enumerate the tag for diagnostic reporting, skipped-step detection, or cross-app coordination. The step still runs and sets the tag, but the tag is effectively invisible to the rest of the upgrade infrastructure.

## Best Practice

For every upgrade-tag constant referenced in `HasUpgradeTag`/`SetUpgradeTag`, register it in the subscriber that matches its trigger scope: tags used from `OnUpgradePerCompany` go in `OnGetPerCompanyUpgradeTags`; tags used from `OnUpgradePerDatabase` go in `OnGetPerDatabaseUpgradeTags`. Keep the tag string in a single source (Label or function) and reference it at the guard, the setter, and the registration.

See sample: `register-upgrade-tags-with-subscribers.good.al`.

## Anti Pattern

Adding a new `UpgradeTag.SetUpgradeTag(MyTag())` without the matching `PerCompanyUpgradeTags.Add(MyTag())` in the registration subscriber. The code compiles and the step completes, but the tag is unregistered and the infrastructure is partially disabled.

See sample: `register-upgrade-tags-with-subscribers.bad.al`.
