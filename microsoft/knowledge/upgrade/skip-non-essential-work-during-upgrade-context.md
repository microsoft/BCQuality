---
bc-version: [all]
domain: upgrade
keywords: [executioncontext, upgrade, reportselections, initialization, install]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Skip non-essential initialization when ExecutionContext is Upgrade

## Description

Initialization code that inserts default rows — report selections, number-series, setup-table defaults — is correct on first install and harmful during upgrade. Existing tenants already have these rows, possibly customized; re-running the initialization either fails on primary-key conflicts or silently overwrites customer configuration. The platform exposes `GetExecutionContext()` so the same procedure can be safely called from install and upgrade paths without duplicating the insert logic.

## Best Practice

Check `if GetExecutionContext() = ExecutionContext::Upgrade then exit;` at the top of idempotent-on-install-only procedures. Keep the early exit narrow and document the reason. The check should be additive to existing guards, not a replacement for proper primary-key handling in the insert itself.

See sample: `skip-non-essential-work-during-upgrade-context.good.al`.

## Anti Pattern

A procedure that unconditionally inserts a default report-selection, number-series, or setup row, called from both install and upgrade paths. On upgrade it either throws on the conflicting key or overwrites the tenant's existing configuration.

See sample: `skip-non-essential-work-during-upgrade-context.bad.al`.
