---
bc-version: [all]
domain: performance
keywords: [modifyall, deleteall, bulk, loop, modify, set-based]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use ModifyAll only for equivalent bulk assignments

## Description

`ModifyAll` assigns one value to one field across the filtered set. It does not run the field's `OnValidate` trigger. Its optional `RunTrigger` parameter controls the table `OnModify` trigger, not field validation. Replacing a loop is therefore correct only when direct assignment is semantically equivalent for every row.

## Best Practice

Use `ModifyAll` when the loop directly assigns the same value, does not call `Validate`, needs no per-row calculation, and does not depend on `OnModify` unless the equivalent `RunTrigger` value is supplied. Check whether table-extension triggers, event subscribers, global triggers, or media fields force row-by-row fallback (see `triggers-and-media-field-regress-modifyall.md`).

See sample: `prefer-modifyall-over-per-row-modify.good.al`.

## Anti Pattern

A loop that only assigns a constant and calls `Modify(false)` on a field with no validation side effects. Conversely, replacing `Validate(Field, Value); Modify(true)` with `ModifyAll(Field, Value)` is also an anti-pattern because it silently drops field validation and may drop table-trigger behavior.

See sample: `prefer-modifyall-over-per-row-modify.bad.al`.
