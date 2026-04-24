---
bc-version: [all]
domain: performance
keywords: [event, subscriber, modifyall, deleteall, bulk, row-by-row]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Table event subscribers force ModifyAll and DeleteAll to run row-by-row

## Description

`ModifyAll` and `DeleteAll` normally compile to a single set-based SQL UPDATE or DELETE. That optimization is conditional: if any subscriber is bound to the table's modify or delete events — `OnBeforeModifyEvent`, `OnAfterModifyEvent`, `OnBeforeDeleteEvent`, `OnAfterDeleteEvent`, and their Rec counterparts — the server must invoke AL per affected row so the subscriber sees each record. The operation falls back to a row-by-row loop, one SQL statement per row, inside the same transaction.

The slowdown is invisible in the caller's source: the call site still reads as a bulk operation. It only shows up under load, and adding an apparently cheap subscriber (even an empty one, or one that guards on a condition and returns) is enough to trigger the fallback for every caller of ModifyAll/DeleteAll on that table across the system. Central tables — Item Ledger Entry, G/L Entry, Sales Line — are the worst places to attach such subscribers because every extension's bulk operation pays the cost.

## Best Practice

Before subscribing to a table's modify or delete events, consider whether the logic can live elsewhere — on the triggering action, on a specific OnValidate, or on a business-event publisher. If the subscriber is unavoidable, scope it as narrowly as possible and document that it forces row-by-row execution so future maintainers understand the cost. Watch PRs that add such subscribers to heavily-modified tables.

## Anti Pattern

An empty or nearly-empty `OnAfterModifyEvent` subscriber on `Sales Line` added as a placeholder for future integration. Every `ModifyAll` on `Sales Line` — in the base app, in every extension, in every tenant — now runs one SQL UPDATE per row.
