---
bc-version: [27..]
domain: agents
keywords: [upgrade, setinstructions, navapp-getresourceastext, existing-instances, upgrade-tag]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reapply resource instructions to existing agent instances on upgrade

## Description

Static instructions stored as an app resource are copied onto an instance only when you call `SetInstructions`. Shipping a new `Instructions.txt` in version 2.0 does not update agents created under 1.0. Models change the resource and assume running instances pick it up.

## Best Practice

In the upgrade codeunit, find existing instances of your metadata provider and call `SetInstructions` again with `NavApp.GetResourceAsText`. Guard with an upgrade tag so the rewrite runs once per version that changes the file.

See sample: [`reapply-resource-instructions-on-upgrade.good.al`](reapply-resource-instructions-on-upgrade.good.al).

## Anti Pattern

Editing only the resource file, or calling `SetInstructions` solely from the first-time setup path. Detection signal: instruction resource in `resourceFolders` with no upgrade procedure that re-applies it.

See sample: [`reapply-resource-instructions-on-upgrade.bad.al`](reapply-resource-instructions-on-upgrade.bad.al).
