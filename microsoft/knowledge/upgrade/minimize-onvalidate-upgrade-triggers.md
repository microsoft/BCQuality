---
bc-version: [all]
domain: upgrade
keywords: [on-validate-upgrade-per-company, performance-impact, bounded-query, justification, read-only-check]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep upgrade validation checks bounded

## Description

Triggers such as `OnValidateUpgradePerCompany` run on every upgrade pass. A full-table scan or cross-table validation therefore adds cost to every upgrade of every tenant. Validation is a read-only lifecycle check, so it cannot make itself one-time by writing an upgrade tag.

## Best Practice

Filter directly to invalid rows and use `IsEmpty` or another bounded existence check where possible. If a broad validation is unavoidable, document the invariant that requires it and keep all data changes in `OnUpgrade...`.

See sample: `minimize-onvalidate-upgrade-triggers.good.al`.

## Anti Pattern

Reading every record in `OnValidateUpgradePerCompany` when a filtered existence check can prove the same invariant. The scan repeats on every upgrade.

See sample: `minimize-onvalidate-upgrade-triggers.bad.al`.
