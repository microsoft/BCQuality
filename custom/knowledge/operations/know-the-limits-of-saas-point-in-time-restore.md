---
bc-version: [all]
domain: operations
keywords: [saas-restore, point-in-time, backup, retention, sandbox, production]
technologies: [powershell]
countries: [w1]
application-area: [all]
---

# Know the limits of SaaS point-in-time restore

## Description

A Business Central SaaS point-in-time restore is bounded by hard platform limits that decide whether a restore is even possible, and by what the platform does and does not bring back. Before promising a customer a restore, you need to know these limits: the backup retention window is the last 28 days, restores are capped per calendar month, the restore must stay in the same Azure region, the localisation cannot change, and a sandbox cannot be restored to production (the allowed paths are production to production, production to sandbox, and sandbox to sandbox). Promising a restore that the limits forbid, or assuming integrations come back live, sets a false expectation during an incident, which is the worst moment to discover a constraint.

The restore is not a snapshot that comes up identical to the source. It is a managed operation that rebuilds business data and then deliberately neutralises anything that could fire against stale data or reach the wrong system, so the difference between what is restored and what is reset is the part a hand-off most often gets wrong.

## Best Practice

Check feasibility against the limits before committing: confirm the desired restore point is within the last 28 days, the target is in the same Azure region, the localisation is unchanged, and the path is allowed. Know what comes back and what does not. Business data, posted documents, master and setup data are restored; AppSource apps return at their latest hotfix even if newer than the restore point; dev-only extensions installed from VS Code are not in the backup and must be reinstalled. The most surprising part is that integrations come up disabled or cleared on purpose, so they cannot fire on stale data, which means a post-restore checklist of re-enabling and re-credentialing each one and running smoke tests. Tell the customer up front about downtime, lost work after the restore point, and integrations needing manual reconnection.

## Anti Pattern

Promising or attempting a restore without checking the limits, or assuming the restored environment comes up exactly as it was. The consequences: a restore that is simply not allowed (cross-region, localisation change, sandbox to production, outside the 28-day window, or over the monthly cap), or a customer surprised that integrations are off and post-restore work is gone. The signal: a restore committed to before the restore point, region, localisation, path, and retention window have been confirmed, or a hand-off that does not warn about disabled integrations and lost post-restore-point work.

## See also

- `restrict-bc-environments-with-an-entra-security-group.md`
