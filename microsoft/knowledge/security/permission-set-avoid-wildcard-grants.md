---
bc-version: [all]
domain: security
keywords: [permissionset, wildcard, rimd, tabledata, least-privilege]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Avoid wildcard grants in permission sets

## Description

A `permissionset` object can grant access object-by-object or with the `*` wildcard. Wildcard grants — `tabledata * = RIMD` (Read/Insert/Modify/Delete on every table) and `table * = X` (Execute on every table object) — collapse the principle of least privilege into a single line and are almost never what the author intended. The grant binds for the lifetime of the permission set wherever it is assigned, including indirectly via role assignment. Permission sets should be granular and role-specific, enumerating only the objects the role actually needs.

## Best Practice

Enumerate each `tabledata` and each `table` entry explicitly. Grant only the letters required: `R` for read-only consumers, `RIM` for editors that do not delete, `RIMD` only for owners of the data. When a role needs Execute on objects, list those objects rather than using `table *`. See sample: [`permission-set-avoid-wildcard-grants.good.al`](permission-set-avoid-wildcard-grants.good.al).

## Anti Pattern

`Permissions = tabledata * = RIMD;` and `Permissions = table * = X, tabledata * = R;` — both grant access to objects the role's author never inspected, and the grant silently broadens every time a new table ships in the platform or in another extension. Reviewers should flag any `*` on the left-hand side of a `tabledata` or `table` entry. See sample: [`permission-set-avoid-wildcard-grants.bad.al`](permission-set-avoid-wildcard-grants.bad.al).
