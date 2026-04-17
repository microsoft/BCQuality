---
bc-version: [26..28]
domain: performance
keywords: [insert, modify, delete, triggers, parameters]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Choose Insert, Modify, and Delete parameters deliberately

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Insert, Modify, and Delete accept a boolean that controls whether the table's OnInsert / OnModify / OnDelete trigger fires. Running the trigger for scratch or migrated data is often unnecessary work — side effects, posting rules, validations — for rows that were already validated upstream. Running the trigger when application logic depends on it is non-negotiable.

## Best Practice

Call Insert(true), Modify(true), or Delete(true) when the table's trigger logic is part of the operation's semantics. Call Insert(false), Modify(false), or Delete(false) when the operation is bulk data movement or temporary-table manipulation and the trigger would duplicate work or fire invalid side effects.

See sample: `use-insert-false-when-skipping-triggers.good.al`.

## Anti Pattern

Blindly passing `true` everywhere pays for triggers on rows that do not need them. Blindly passing `false` silently skips validations that the table's author intended to be mandatory.

