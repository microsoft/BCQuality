---
bc-version: [all]
domain: data-modeling
keywords: [last-date-modified, onmodify, onrename, audit-field, non-editable, stale-value]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Refresh `Last Date Modified` in both `OnModify` and `OnRename`

## Description

Master tables carry a non-editable `Last Date Modified` field of type `Date`. It records when the record last changed and is refreshed by table triggers, not by the user. The refresh must happen in **both** `OnModify` and `OnRename`.

The reason is a BC-specific trap: renaming a record changes its primary key and fires `OnRename` — it does **not** fire `OnModify`. A table that updates `Last Date Modified` only in `OnModify` therefore leaves a stale date behind every rename. Downstream logic that keys on this field (incremental sync, integration deltas, "changed since" reports) then silently skips the renamed record. Assign `Today` (the system date), not `WorkDate`, because the field reflects the real modification moment.

## Best Practice

Both `OnModify` and `OnRename` set `"Last Date Modified" := Today();`, and the field is declared `Editable = false` so only the triggers maintain it.

See sample: `set-last-date-modified-in-onmodify-and-onrename.good.al`.

## Anti Pattern

Only `OnModify` assigns `Last Date Modified`. After a rename the value is stale, and any process that trusts it to detect changes misses the record.

See sample: `set-last-date-modified-in-onmodify-and-onrename.bad.al`.
