---
bc-version: [all]
domain: testing
keywords: [license, entitlement, posted-tables, ledger, direct-insert, sandbox, saas, test-runner, environmental-failure, triage]
technologies: [al]
countries: [w1]
application-area: [all]
---

# License-entitlement failures on posted tables in a SaaS test run are environmental

> Contributions welcome — open a PR to refine or extend this article.

## Description

A test session against a SaaS sandbox runs under the signed-in user's **license entitlement**, and entitlements grant only indirect access to posted and ledger tables. A test helper that inserts directly into such a table fails with `Your license does not grant you the following permissions on TableData <table>: Insert`. This is a license check, not a permission-set check: `TestPermissions = Disabled` and `SUPER` do not lift it. The same test is green under a container or pipeline test runner, whose license does not carry the restriction. The failure is therefore environmental — it says where the test ran, not that the change under review broke anything.

## Best Practice

Triage a license-entitlement failure on a posted or ledger table as environment-limited before suspecting the diff: confirm the same test failed identically on the pre-change baseline in the same environment. For a durable fix, create posted data through posting — the test library codeunits (`Library - Sales`, `Library - Purchase`) create and post documents — so the test runs under any license and exercises the posting path it depends on.

See sample: `license-entitlement-failures-on-posted-tables-are-environmental.good.al`.

## Anti Pattern

Reporting the failure as a regression of the change under review, "fixing" it by adding `TestPermissions = Disabled` or a broader permission set (neither is consulted by the license check), or building fixtures by `Init` + direct `Insert` into a posted table, which passes only where the runner's license allows it.

See sample: `license-entitlement-failures-on-posted-tables-are-environmental.bad.al`.
