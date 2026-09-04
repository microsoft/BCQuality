---
bc-version: [all]
domain: upgrade
keywords: [upgrade-tag, nesting, complexity, upgrade-per-company, upgrade-per-database]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep upgrade tag conditional logic to at most two levels of nesting

## Description

The conditional logic that gates upgrade code behind an upgrade tag should be at most two levels deep: check the tag, exit if already applied, otherwise run the upgrade step. Deeper nesting — tag checks inside tag checks, or a tag check combined with multi-branch business-data conditions — signals that the upgrade step is trying to do more than one thing, or that it is reconstructing decision logic that belongs in the tag structure itself (one tag per distinct upgrade step), not in nested `if` statements inside a single step.

Upgrade code runs unattended, once, against production data with no chance to interactively debug a wrong branch. The cost of a nesting-driven mistake here is much higher than in ordinary application code, which is why the ceiling is lower than general AL style would otherwise allow.

## Best Practice

One tag check, one exit, one upgrade action — two levels deep at most.

See sample: `upgrade-tag-logic-must-not-nest-deeply.good.al`.

## Anti Pattern

Nesting the tag check, a record loop, and a multi-branch business condition inside one procedure. Split the buried business condition into its own, separately tagged upgrade step instead.

See sample: `upgrade-tag-logic-must-not-nest-deeply.bad.al`.
