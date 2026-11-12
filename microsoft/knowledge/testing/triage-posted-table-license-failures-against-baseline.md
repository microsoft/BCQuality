---
bc-version: [all]
domain: testing
keywords: [license, entitlement, posted-tables, ledger, direct-insert, sandbox, saas, baseline, triage]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Compare posted-table license failures with the same-environment baseline

## Description

A test fixture that directly inserts into a posted or ledger table can fail with `Your license does not grant you the following permissions on TableData <table>: Insert` when that environment's license allows only indirect insertion through an authorized object. This is not a universal restriction on every SaaS identity or every posted table: establish the effective rights and failing operation. `TestPermissions` governs the runner's permission-set execution context; `Disabled` skips permission lowering in the standard runner (tests execute as `SUPER`), but neither setting nor `SUPER` expands the user's license entitlement. A pass in a container/development-license environment known to permit that direct access does not prove the fixture works with the target user's rights; a pipeline can target SaaS too.

## Best Practice

Compare the failing test with the identical pre-change test in the same environment, with the same user/license context, installed dependencies and company setup. Only an identical baseline failure supports classifying it as pre-existing/environment-limited relative to the diff, rather than a regression caused by that diff. Keep the underlying direct-write fixture problem explicit even then; if the baseline is unavailable, attribution remains unproven. If the diff introduces the direct insert, report a new fixture defect, not an environmental exemption.

For ordinary fixtures requiring posted data, create and post a document through the matching test library and standard posting routine rather than inserting a posted header or ledger entry yourself. The sample uses `Library - Purchase` to create an invoice and post it; this requires the target version's test libraries, valid posting setup, and a user licensed and permitted to post purchases. It is not a promise of success under any license. Temporary records and deliberate tests of denied low-level access are not ordinary posted-data fixtures.

See sample: [`triage-posted-table-license-failures-against-baseline.good.al`](triage-posted-table-license-failures-against-baseline.good.al).

## Anti Pattern

Dismissing a newly introduced direct insert into a real posted table as "just SaaS", blaming an unrelated diff for an identical same-environment baseline failure, or broadening permission sets/adding `TestPermissions = Disabled` to repair a confirmed license denial. Adding an object `Permissions` property can enable indirect access, but turning the direct insert green that way does not repair the ordinary posted-data fixture or exercise posting invariants. Treating every `Init`/`Insert` or every permission error as this scenario also misdiagnoses the problem: identify the real table, operation, effective rights and baseline first.

See sample: [`triage-posted-table-license-failures-against-baseline.bad.al`](triage-posted-table-license-failures-against-baseline.bad.al).

## References

- [Entitlement object: effective permissions are the intersection of entitlement and assigned permissions](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-entitlement-object).
- [Permissions property: indirect access and posting routines](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-permissions-property).
- [TestPermissions property: runner-controlled permission sets](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-testpermissions-property).
- [BCApps 29.2 purchase test library: CreatePurchaseInvoice and PostPurchaseDocument](https://github.com/microsoft/BCApps/blob/c97b2249a827e8d9cf822b5c45488438f805c236/src/Layers/W1/Tests/ApplicationTestLibrary/LibraryPurchase.Codeunit.al#L320-L333) and [Purch.-Post permissions](https://github.com/microsoft/BCApps/blob/c97b2249a827e8d9cf822b5c45488438f805c236/src/Layers/W1/BaseApp/Purchases/Posting/PurchPost.Codeunit.al#L74-L93).
- Related: [general fixture construction](use-library-codeunits-for-test-fixtures.md) and [entitlement boundaries](../security/do-not-grant-rights-beyond-a-users-entitlement.md). This article adds baseline-relative failure attribution, not a new licensing model.

Originally contributed by [NavNab](https://github.com/NavNab) in [PR #141](https://github.com/microsoft/BCQuality/pull/141).
