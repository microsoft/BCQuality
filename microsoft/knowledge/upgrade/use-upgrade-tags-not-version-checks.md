---
bc-version: [all]
domain: upgrade
keywords: [upgrade-tag, dataversion, version-check, idempotent, guard]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Guard upgrade steps with upgrade tags, not version checks

## Description

`DataVersion()` comparisons tie an upgrade step to a specific release cadence: if the step is skipped or fails on one version and the tenant upgrades past the check before the step succeeds, the step never runs. Upgrade tags, managed by `Codeunit "Upgrade Tag"`, record per-step completion in the tenant database. A tag-guarded step runs once, retries cleanly after failure, and remains idempotent across future versions regardless of the version the customer is upgrading from.

## Best Practice

Guard each step with `if UpgradeTag.HasUpgradeTag(MyTag()) then exit;` at the top of the procedure. After the step completes, call `UpgradeTag.SetUpgradeTag(MyTag())`. Define the tag string in a `Tok`-suffixed Label or returning function so the same constant is referenced at both the guard and the registration (see `register-upgrade-tags-with-getpercompany-getperdatabase-subscribers`).

See sample: `use-upgrade-tags-not-version-checks.good.al`.

## Anti Pattern

`if MyApp.DataVersion().Major < 18 then UpgradeFeatureA();` — the step runs on every upgrade from a pre-18 version, may fail on partial data, and the next retry re-runs work that already succeeded. Nesting version-check branches (`< 14` → step A, `< 17` → step B) compounds the fragility.

See sample: `use-upgrade-tags-not-version-checks.bad.al`.
