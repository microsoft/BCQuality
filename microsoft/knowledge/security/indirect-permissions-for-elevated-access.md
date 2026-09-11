---
bc-version: [all]
domain: security
keywords: [permissionset, indirect-permissions, ri, ii, mi, di, code-mediated]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use indirect permissions when access must be code-mediated

## Description

In a `permissionset`, uppercase letters (`R`, `I`, `M`, `D`) grant **direct** permissions: the assignee can read, insert, modify, or delete the table data through any UI or API surface. Lowercase letters (`r`, `i`, `m`, `d`) grant **indirect** permissions: the operation is allowed only when it is invoked from AL code that itself holds the corresponding direct permission. Indirect permissions let a role consume privileged tables through controlled procedures (a report, a posting routine) without giving users a way to read or change those tables outside the intended code path.

## Best Practice

Use indirect permissions (`ri`, `ii`, `mi`, `di`) when a role needs access to a sensitive table only through a specific codeunit or report — for example, a "Report Runner" role that reads `G/L Entry` only via published reports. Pair the indirect grant with the codeunit or report that mediates access; that object's own permissions (or InherentPermissions) supply the direct rights. Document why indirect permissions are required in the permission set or in the consuming object's comments. See sample: [`indirect-permissions-for-elevated-access.good.al`](indirect-permissions-for-elevated-access.good.al).

## Anti Pattern

Granting `RIMD` on a sensitive table when the role only needs to view it through a report — for example `tabledata "G/L Entry" = RIMD` on a "Report Runner" role. Users assigned that role can now query and modify ledger entries directly through any client that respects the permission, bypassing the report entirely. Reviewers should look for uppercase grants on system-of-record tables (G/L Entry, ledger entries, posted documents) where the consuming code path is clearly read-through-report or read-through-API. See sample: [`indirect-permissions-for-elevated-access.bad.al`](indirect-permissions-for-elevated-access.bad.al).
