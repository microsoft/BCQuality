---
bc-version: [all]
domain: upgrade
keywords: [upgrade-tag, nesting, complexity, upgrade-per-company, upgrade-per-database]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Never nest upgrade tag checks or blend two migrations under one tag

## Description

Upgrade tag *checks* should stay flat: never nest one tag's existence check inside another tag's guarded body, and never let one tagged procedure quietly perform a second, functionally distinct migration — that turns two upgrade steps into one that can't be tracked, skipped, or fixed independently, which is exactly what separate tags exist to prevent. That is the specific nesting Microsoft's own guidance warns against ("Keep tags simple by limiting nesting tags to two levels").

That is not a limit on how much conditional logic a single migration's own loop body may contain. Microsoft's own worked example for upgrade tags nests a record loop with two business-data safety conditions — a corruption guard, then a redundant-write guard — inside one `if UpgradeTagMgt.HasUpgradeTag(...) then exit;`-guarded procedure, and its own design guidance separately *requires* this: "Implement extra safety checks to avoid data corruption, even though you're using upgrade tags." A business-data guard that protects the single migration a tag represents is not a second migration hiding inside the first, however many `if` levels it takes.

Upgrade code runs unattended, once, against production data with no chance to interactively debug a wrong branch — which is why mixing two migrations under one tag, or losing track of which tag guards which step, is a genuinely higher-cost mistake here than the equivalent would be in ordinary application code.

## Best Practice

One tag, one migration: exit early if the tag is already set, then run the one upgrade step that tag represents — including as many business-data safety conditions as that single step's own correctness requires, nested however deep the logic actually needs. Reach for a second, separately tagged migration only when the nested logic is doing genuinely unrelated work (a different table, a different field, a different concern) that could legitimately be skipped, retried, or fixed on its own.

See sample: [`upgrade-tag-logic-must-not-nest-deeply.good.al`](upgrade-tag-logic-must-not-nest-deeply.good.al).

## Anti Pattern

Checking one upgrade tag inside the guarded body of another, or writing two functionally unrelated migrations — different tables, different concerns — under a single tag so neither can be tracked, skipped, or fixed independently of the other. A record loop with business-data safety conditions inside one tagged migration's own body is not this anti-pattern, even several `if` levels deep, as long as every condition serves that one migration.

See sample: [`upgrade-tag-logic-must-not-nest-deeply.bad.al`](upgrade-tag-logic-must-not-nest-deeply.bad.al).

## Source

Microsoft's own "Upgrading Extensions" guidance, Design considerations: "Keep tags simple by limiting nesting tags to two levels. Complicated if statements can lead to problems." — https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-upgrading-extensions#using-upgrade-tags-to-control-upgrade-code
