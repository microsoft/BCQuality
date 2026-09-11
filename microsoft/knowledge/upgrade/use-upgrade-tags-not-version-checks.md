---
bc-version: [all]
domain: upgrade
keywords: [upgrade-tag, version-check, dataversion, has-upgrade-tag, set-upgrade-tag, control-flow, dynamic-check, runtime-function, always-log-table, non-persisted-state]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Control upgrade execution with upgrade tags, not version checks

## Description

Each piece of upgrade logic must run exactly once per company (or database) across the lifetime of an extension. The platform mechanism for that is the `Upgrade Tag` codeunit: a procedure asks `HasUpgradeTag(MyTag())` at entry, performs its work, then calls `SetUpgradeTag(MyTag())` to record completion. Subsequent upgrades on the same tenant see the tag and skip the work. Hand-rolled `if MyApp.DataVersion().Major < N then ...` chains are the wrong tool: they are version-coupled, accumulate stale branches over time, and break when a tenant skips a version.

## Scope

Upgrade tags guard one-time work that mutates persisted, per-company state (data, setup records, or a stored schema baseline) so it runs exactly once. They do not apply to a hard-coded list or condition inside an ordinary runtime function that is evaluated fresh on every call and never persists its result — for example, a function that decides live whether a given table is in the "always log changes" set for the change-log feature. Adding or removing an entry from such a list is a normal behavior change: it only affects future evaluations of the function, there is no stored per-company flag or record whose absence would leave old data stranded, so no upgrade tag, upgrade codeunit, or migration step is needed.

## Best Practice

Every upgrade procedure starts with a `HasUpgradeTag` guard and ends with `SetUpgradeTag` once the work is committed. Each feature gets its own tag string so features can be re-run independently if needed.

See sample: [`use-upgrade-tags-not-version-checks.good.al`](use-upgrade-tags-not-version-checks.good.al).

## Anti Pattern

Branching on `MyApp.DataVersion().Major > N`, or chains of `< N` / `< M` to decide which upgrade step to run. Such code becomes unmaintainable after a few releases and silently does the wrong thing on tenants that skip versions.

See sample: [`use-upgrade-tags-not-version-checks.bad.al`](use-upgrade-tags-not-version-checks.bad.al).

## See also

- `first-install-dataversion-zero-check.md` — the one situation where reading `DataVersion()` is the right call.
- `register-upgrade-tags-with-subscribers.md` — how to make a tag known to the platform.
