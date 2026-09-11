---
bc-version: [all]
domain: privacy
keywords: [retention-policy, allowed-tables, addallowedtable, reten-pol-allowed-tables, log-table-growth, mandatory-minimum-retention, install-upgrade-codeunit]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Extension-owned log tables must be registered as retention-policy allowed tables

## Description

The retention policy engine only ever deletes from tables that appear in its allowed-tables list, and an extension may register only tables it owns — it cannot add a base application table or a table from another extension. Registration is a call to `Codeunit "Reten. Pol. Allowed Tables".AddAllowedTable`, passing the table ID and the field number of the Date or DateTime field that ages each record (`SystemCreatedAt` is the usual choice). Until that call has run in a company, the table cannot be selected on the **Retention Policies** page at all, so an activity log, integration log, or archive table the extension writes to grows with no supported way for an administrator to trim it. The registration is stored per company and is not part of the table's metadata — it exists only because install or upgrade code put it there.

## Best Practice

Register every table the extension owns that accumulates rows over time: activity and audit logs, integration and API request logs, archived documents. Call a shared routine from both the install codeunit (`OnInstallAppPerCompany`) and an upgrade codeunit (`OnUpgradePerCompany`), because install code does not run when an existing installation moves to a new version — registration added only to install code never reaches tenants that already have the app. Guard the routine with `IsAllowedTable` and an upgrade tag so repeated runs are idempotent. Pass `MandatoryMinRetenDays` when the data must survive a minimum period for audit or support reasons; the platform then rejects any shorter period an administrator configures. When only a subset of rows should ever expire, build the filter with `AddTableFilterToJsonArray` and pass it to the `AddAllowedTable` overload that takes a `JsonArray` — a filter added as locked cannot be removed later by the administrator.

Registering a table only makes it eligible; the policy itself is a separate concern, covered by [`ship-a-default-retention-policy-setup.md`](ship-a-default-retention-policy-setup.md).

See sample: [`register-owned-log-tables-for-retention-policies.good.al`](register-owned-log-tables-for-retention-policies.good.al).

## Anti Pattern

An extension-owned log table with no `AddAllowedTable` call anywhere in the app, cleaned instead by hand-rolled code — a job queue codeunit or scheduled task running `DeleteAll` against a hard-coded date window. The deletion happens outside the **Retention Policy Log**, the administrator has no page on which to lengthen, shorten, or disable it, and the table is invisible during a data-retention review. The same defect in slower form is registration performed only in the install codeunit: new tenants are covered, every existing tenant stays unregistered after the upgrade.

See sample: [`register-owned-log-tables-for-retention-policies.bad.al`](register-owned-log-tables-for-retention-policies.bad.al).

## References

- [Clean up data with retention policies](https://learn.microsoft.com/en-us/dynamics365/business-central/admin-data-retention-policies), section *Include your extension in a retention policy*.
- [`RetenPolAllowedTables.Codeunit.al`](https://github.com/microsoft/BCApps/blob/main/src/System%20Application/App/Retention%20Policy/src/Retention%20Policy%20Allowed%20Tables/RetenPolAllowedTables.Codeunit.al) in microsoft/BCApps — the `AddAllowedTable` overloads, `IsAllowedTable`, and `AddTableFilterToJsonArray`.
