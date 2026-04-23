---
bc-version: [all]
domain: security
keywords: [indirect-permission, elevation, permissionset]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use indirect permissions for elevated access

> Contributions welcome — open a PR to refine or extend this article.

## Description

Indirect permissions (ri, ii, mi, di) let a procedure perform an operation against tabledata the caller does not have direct rights to, provided the caller is authorized to invoke the procedure. They are the supported mechanism for elevation: instead of widening every caller's direct rights to M or D, the sensitive operation lives in a codeunit that holds the indirect right and validates its callers.

## Best Practice

Where a module exposes a controlled write or delete against a sensitive table, grant the codeunit (or the helper permission set it assumes) the indirect permission (mi, di) it requires, keep direct permissions minimal, and document why the elevation is justified. The helper MUST validate its inputs and the caller's identity before performing the elevated work.

See sample: `use-indirect-permissions-for-elevated-access.good.al`.

## Anti Pattern

Granting direct M or D on a sensitive tabledata to every role that might invoke a helper, because authoring an indirect-permission codeunit was inconvenient. Every caller now has the elevated right for every code path, not just the one the helper implements.

See sample: `use-indirect-permissions-for-elevated-access.bad.al`.

