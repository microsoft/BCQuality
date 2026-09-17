---
bc-version: [all]
domain: security
keywords: [inherentpermissions, inherententitlements, attribute, least-privilege, procedure]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Grant the minimum InherentPermissions a procedure needs

## Description

`[InherentPermissions(PermissionObjectType::..., ...)]` and `[InherentEntitlements(Entitlement::...)]` are method-level attributes that let a procedure perform an operation on the listed object even when the caller's permission set does not allow it. They effectively elevate the caller for the duration of the procedure. The grant therefore needs to be as narrow as the procedure's actual work — both in object scope (the specific table) and in operation (`'r'` versus `'RIMD'`). Overly broad inherent permissions silently expand the attack surface of every codeunit that calls the procedure.

## Best Practice

Match the inherent permission to the procedure's body: a procedure that only reads `Customer.Name` declares `[InherentPermissions(PermissionObjectType::TableData, Database::Customer, 'r')]`, not `'RIMD'`. Pick the inherent entitlement that matches the lowest tier the procedure should run under — do not require Premium for a procedure that performs an Essential-tier check. See sample: [`inherent-permissions-minimal-grant.good.al`](inherent-permissions-minimal-grant.good.al).

## Anti Pattern

Declaring `[InherentPermissions(..., 'RIMD')]` on a read-only procedure (`GetCustomerName`), or `[InherentEntitlements(Entitlement::"Dynamics 365 Business Central Premium")]` on a procedure that performs a simple existence check. Reviewers should compare the attribute's permission letters against what the procedure body actually does and flag any grant broader than the operations performed. See sample: [`inherent-permissions-minimal-grant.bad.al`](inherent-permissions-minimal-grant.bad.al).
