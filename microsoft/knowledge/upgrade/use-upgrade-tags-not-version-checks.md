---
bc-version: [all]
domain: upgrade
keywords: [upgrade-tag, version-check, dataversion, has-upgrade-tag, set-upgrade-tag, control-flow]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Control upgrade execution with upgrade tags, not version checks

## Description

Each piece of upgrade logic must run exactly once per company (or database) across the lifetime of an extension. The platform mechanism for that is the `Upgrade Tag` codeunit: a procedure asks `HasUpgradeTag(MyTag())` at entry, performs its work, then calls `SetUpgradeTag(MyTag())` to record completion. Subsequent upgrades on the same tenant see the tag and skip the work. Hand-rolled `if MyApp.DataVersion().Major < N then ...` chains are the wrong tool: they are version-coupled, accumulate stale branches over time, and break when a tenant skips a version.

## Best Practice

Every upgrade procedure starts with a `HasUpgradeTag` guard and ends with `SetUpgradeTag` once the work is committed. Each feature gets its own tag string so features can be re-run independently if needed.

See sample: [`use-upgrade-tags-not-version-checks.good.al`](use-upgrade-tags-not-version-checks.good.al).

## Anti Pattern

Branching on `MyApp.DataVersion().Major > N`, or chains of `< N` / `< M` to decide which upgrade step to run. Such code becomes unmaintainable after a few releases and silently does the wrong thing on tenants that skip versions.

See sample: [`use-upgrade-tags-not-version-checks.bad.al`](use-upgrade-tags-not-version-checks.bad.al).

## See also

- `first-install-dataversion-zero-check.md` — the one situation where reading `DataVersion()` is the right call.
- `register-upgrade-tags-with-subscribers.md` — how to make a tag known to the platform.
