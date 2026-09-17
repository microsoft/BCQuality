---
bc-version: [all]
domain: upgrade
keywords: [released-baseline, unreleased, schema, migration, obsolete, data-loss, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Unreleased schema changes need no upgrade or migration path

## Description

Upgrade and migration findings protect data and schema that have already shipped to customers. A schema element — a table, field, key, or enum — that is new in this app, or was added and then changed within the same still-unreleased development cycle, needs no upgrade code or migration path: no customer has data in it yet, so there is nothing to preserve or migrate. Such a change is not an obsoletion, data-loss, or breaking-migration defect.

Release status is established from the diff, the app's `app.json` version, or a released baseline. A schema element with no released baseline has no persisted customer data to protect.

## Best Practice

Before asserting an obsoletion, data-loss, or breaking-migration defect, establish that the affected table, field, key, or enum existed in a released version. Do not require upgrade or migration code for schema that never shipped. When release status cannot be established from the diff, `app.json`, or a released baseline, omit the finding rather than demand a migration path.

## Anti Pattern

Demanding an upgrade codeunit, migration path, or data-preservation step, or flagging data loss, for a table, field, key, or enum that is new in the current unreleased cycle and has no released baseline.
