---
bc-version: [all]
domain: privacy
keywords: [retention-policy-setup, retention-period, default-policy, unbounded-table-growth, opt-in-deletion, upgrade-tag]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Registering a table is not a retention policy — ship a default setup

## Description

`AddAllowedTable` only makes a table selectable on the **Retention Policies** page. Nothing is deleted until a `Retention Policy Setup` record exists for that table, names a `Retention Period`, and is enabled. An extension that registers its log tables and stops there ships unbounded growth as its default behaviour: the administrator has to discover the page, know which of the extension's tables are safe to trim, and pick a period the extension's own author never documented. Microsoft's `Codeunit 3907 "Retention Policy Installer"` shows the intended shape — it registers `Retention Policy Log Entry`, then creates a setup record with a six-month period on first install, inserted disabled, guarded by an upgrade tag so a policy the administrator later deleted is not recreated on the next upgrade.

## Best Practice

In the same install and upgrade routine that registers the table (see [`register-owned-log-tables-for-retention-policies.md`](register-owned-log-tables-for-retention-policies.md)), create the `Retention Policy Setup` record: reuse an existing `Retention Period` whose `"Retention Period"` enum value matches the period you want and create one only when none exists, then `Validate` `"Table Id"`, `"Apply to all records"` and `"Retention Period"` before inserting. Gate the creation on an upgrade tag so it happens once per company rather than on every upgrade. Default to inserting with `Enabled` set to false: pre-creating the line puts a reviewed, sensible period in front of the administrator while leaving the decision to delete tenant data with them. Shipping the policy enabled is defensible for rows that are purely diagnostic and documented as transient — state that choice, and the default period, in the app's onboarding material either way.

See sample: [`ship-a-default-retention-policy-setup.good.al`](ship-a-default-retention-policy-setup.good.al).

## Anti Pattern

Install code that calls `AddAllowedTable` and treats the table as covered by retention policies. The signal is an install or upgrade routine that touches `Codeunit "Reten. Pol. Allowed Tables"` but never `Record "Retention Policy Setup"`; the symptom is a support case where the extension's log table holds millions of rows on a tenant whose **Retention Policies** page has no line for it. The mirror-image defect is inserting the setup with `Enabled` set to true and no documentation, so the app begins deleting tenant data on a schedule nobody approved.

See sample: [`ship-a-default-retention-policy-setup.bad.al`](ship-a-default-retention-policy-setup.bad.al).

## References

- [Clean up data with retention policies](https://learn.microsoft.com/en-us/dynamics365/business-central/admin-data-retention-policies) — retention periods, enabling a policy, and the job queue entry that applies it.
- [`RetentionPolicyInstaller.Codeunit.al`](https://github.com/microsoft/BCApps/blob/main/src/System%20Application/App/Retention%20Policy/src/Install/RetentionPolicyInstaller.Codeunit.al) in microsoft/BCApps — the platform's own register-then-create-disabled-setup pattern.
