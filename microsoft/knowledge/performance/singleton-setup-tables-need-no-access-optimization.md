---
bc-version: [all]
domain: performance
keywords: [singleton, setup-table, sales-receivables-setup, general-ledger-setup, setloadfields, bounded]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Enforced singleton setup tables need no access optimization

## Description

An access-pattern exemption is valid only for a table whose schema and write paths enforce at most one row for the relevant scope. A conventional blank primary key, a parameterless `Get()`, or a table name ending in `Setup` does not enforce that invariant; another primary-key value can still create another row unless insertion logic prevents it.

## Best Practice

Exempt a setup read only after confirming that noncanonical keys are rejected and every supported creation path preserves the singleton. Otherwise apply ordinary access-pattern analysis, even when existing application code normally uses one blank-key record.

## Anti Pattern

Treating every `*Setup` table or parameterless `Get()` as proof of bounded cardinality without checking the primary key and insertion logic.
