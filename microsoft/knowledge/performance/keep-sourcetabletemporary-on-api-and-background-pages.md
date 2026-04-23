---
bc-version: [all]
domain: performance
keywords: [sourcetabletemporary, tabletype, temporary, api-page, persistence, regression]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not remove SourceTableTemporary or TableType = Temporary without understanding the impact

## Description

`SourceTableTemporary = true` on a page, and `TableType = Temporary` on a table, mean the underlying record operates in memory — Insert/Modify/Delete mutate the session buffer, not the database. Removing either property converts the same operations to real SQL writes. On an API page that external callers hit at high frequency, on a background task that processes thousands of records, or on a UI page that composes an in-memory list for display, the change from temporary to persistent can turn a lightweight operation into a major source of database load. The refactor is easy to propose ("why is this temporary?") and expensive to regret.

## Best Practice

When a diff removes `SourceTableTemporary = true` or `TableType = Temporary`, require justification explaining why persistence is now required and what paths still write. Review the callers for unexpected new writes, transaction scope, trigger fires, and contention. Keep the property unless the change genuinely needs persistence; an unused-looking temporary table on a bounded page is usually there for a reason.

## Anti Pattern

A cleanup PR that deletes `SourceTableTemporary = true` from an API page "because the source table already exists". The API now writes to the real table on every call, every consumer's requests reach the database, and the incidental side-effects in the source table's triggers start firing across tenants.
