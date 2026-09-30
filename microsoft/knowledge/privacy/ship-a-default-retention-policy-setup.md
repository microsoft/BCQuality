---
bc-version: [22..]
domain: privacy
keywords: [retention-policy, retention-policy-setup, addallowedtable, findorcreateretentionperiod, retention-period, default-policy, unbounded-table-growth, opt-in-deletion, upgrade-tag]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Registering a table does not delete anything — consider shipping a default setup

## Description

`AddAllowedTable` only makes a table selectable on the **Retention Policies** page. Nothing is deleted until a `Retention Policy Setup` record exists for that table, names a `Retention Period`, and is enabled. Registration alone is a valid pattern — several Microsoft apps register tables and leave the policy entirely to the administrator — but it means the table keeps growing until someone discovers the page, works out which of the extension's tables are safe to trim, and picks a period. Shipping a default setup is optional; where the extension's author knows a sensible period, it removes that discovery step. Microsoft's `Codeunit 3907 "Retention Policy Installer"` shows the shape — it registers `Retention Policy Log Entry`, then creates a setup record with a six-month period on first install, inserted disabled, guarded by an upgrade tag so a policy the administrator later deleted is not recreated on the next upgrade.

## Best Practice

When you ship a default, do it in the same install and upgrade routine that registers the table (see [`register-owned-log-tables-for-retention-policies.md`](register-owned-log-tables-for-retention-policies.md)), and create the `Retention Policy Setup` record: get the period code from `Codeunit "Retention Policy Setup".FindOrCreateRetentionPeriod`, which reuses an existing `Retention Period` with the requested enum value and otherwise creates one without colliding on an existing code (a hand-written lookup-then-insert fails when a period with the chosen code already exists for a different value), then `Validate` `"Table Id"`, `"Apply to all records"` and `"Retention Period"` before inserting. The codeunit that inserts the record needs `tabledata "Retention Policy Setup" = ri`. Gate the creation on an upgrade tag so it happens once per company rather than on every upgrade. Default to inserting with `Enabled` set to false: pre-creating the line puts a reviewed, sensible period in front of the administrator while leaving the decision to delete tenant data with them. Shipping the policy enabled is defensible for rows that are purely diagnostic and documented as transient — state that choice, and the default period, in the app's onboarding material either way.

See sample: [`ship-a-default-retention-policy-setup.good.al`](ship-a-default-retention-policy-setup.good.al).

## Anti Pattern

Registering a table and then claiming, in a message, notification, label, teaching tip, or setup text, that its data is now cleaned up automatically. Registration only makes the table selectable; without an enabled `Retention Policy Setup` nothing is deleted, so the administrator is told a cleanup is running when none is, and the table grows unnoticed. Registration without a default setup is not itself a defect.

See sample: [`ship-a-default-retention-policy-setup.bad.al`](ship-a-default-retention-policy-setup.bad.al).

## References

- [Clean up data with retention policies](https://learn.microsoft.com/en-us/dynamics365/business-central/admin-data-retention-policies) — retention periods, enabling a policy, and the job queue entry that applies it.
- [`RetentionPolicyInstaller.Codeunit.al`](https://github.com/microsoft/BCApps/blob/main/src/System%20Application/App/Retention%20Policy/src/Install/RetentionPolicyInstaller.Codeunit.al) in microsoft/BCApps — the platform's own register-then-create-disabled-setup pattern.
