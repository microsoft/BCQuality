---
bc-version: [all]
domain: upgrade
keywords: [upgrade-tag, event-subscriber, on-get-per-company-upgrade-tags, on-get-per-database-upgrade-tags, registration]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Register upgrade tags that must be seeded for new companies

## Description

`SetUpgradeTag(Tag)` directly records a completed per-company upgrade step; `HasUpgradeTag(Tag)` can then guard that step on later upgrades. The `OnGetPerCompanyUpgradeTags` subscriber serves a different path: it contributes tags to the list used by `SetAllUpgradeTags()` when a new company is initialized, marking historical upgrade steps complete so they do not run against a company that starts on the current schema.

Registration is not install-time seeding. When an extension is installed into an existing company and a tag must start as complete, the install code must call `SetUpgradeTag` explicitly. For new-company initialization, codeunit `Company Initialize` calls `SetAllUpgradeTags`, which obtains subscriber-provided per-company tags and inserts missing ones. Database-scoped upgrade steps use `HasDatabaseUpgradeTag`/`SetDatabaseUpgradeTag` and the corresponding per-database list.

## Best Practice

In the upgrade codeunit, guard work with `HasUpgradeTag` and call `SetUpgradeTag` only after successful completion. Seed the same tag explicitly from `OnInstallAppPerCompany` when first-install logic should not run as a later upgrade. Also add historical per-company tags to `OnGetPerCompanyUpgradeTags` so `SetAllUpgradeTags` marks them complete for newly created companies. Keep the tag definition shared so all paths use the exact same value.

See sample: `register-upgrade-tags-with-subscribers.good.al`.

## Anti Pattern

Assuming an `OnGetPerCompanyUpgradeTags` subscriber sets tags during extension installation, or omitting the subscriber and allowing old upgrade steps to run when `SetAllUpgradeTags` initializes a new company. The subscriber supplies a list; only `SetAllUpgradeTags` or an explicit `SetUpgradeTag` call persists it.

See sample: `register-upgrade-tags-with-subscribers.bad.al`.
