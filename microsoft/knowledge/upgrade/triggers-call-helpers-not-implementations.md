---
bc-version: [all]
domain: upgrade
keywords: [on-upgrade-per-company, on-upgrade-per-database, trigger-body, helper-procedure, structure]
technologies: [al]
countries: [w1]
application-area: [all]
---

# `OnUpgradePerCompany` / `OnUpgradePerDatabase` should call helpers, not inline logic

## Description

The `OnUpgradePerCompany` and `OnUpgradePerDatabase` triggers on an upgrade codeunit are dispatch points, not implementation slots. They should contain only calls to named local procedures — one call per feature being upgraded. Putting `ModifyAll`, record loops, or any business logic directly inside the trigger body makes the upgrade impossible to read, impossible to selectively skip via upgrade tags per feature, and impossible to extend without touching the trigger itself.

Empty `OnUpgradePerCompany` / `OnUpgradePerDatabase` triggers are acceptable — they may be placeholders for future use or artifacts from cleanup.

## Best Practice

Each upgrade trigger contains an ordered list of procedure calls, one per feature: `UpgradeFeatureA();` `UpgradeFeatureB();`. Each procedure handles its own upgrade tag, its own data work, and can be added or removed independently.

See sample: [`triggers-call-helpers-not-implementations.good.al`](triggers-call-helpers-not-implementations.good.al).

## Anti Pattern

Implementing record loops, `ModifyAll`, or other data work directly in the trigger body. The trigger then mixes orchestration with implementation, and adding a second feature requires editing the trigger rather than appending one line.

See sample: [`triggers-call-helpers-not-implementations.bad.al`](triggers-call-helpers-not-implementations.bad.al).
