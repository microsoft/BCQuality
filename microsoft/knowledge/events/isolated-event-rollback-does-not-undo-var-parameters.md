---
bc-version: [20..]
domain: events
keywords: [isolated-event, isolated, var-parameter, ishandled, onbefore, integration-event, rollback, subscriber-error, side-effects]
technologies: [al]
countries: [w1]
application-area: [all]
---

# An isolated event's rollback does not undo var parameters or other in-memory state

## Description

When a subscriber to an isolated event fails, the platform rolls back only the `Insert`, `Modify`, and `Delete` calls it made on normal tables. Everything else the subscriber changed before the error survives: values assigned to `var` parameters (including `IsHandled`), fields of a `var` record that were never written, globals of single-instance codeunits, temporary-table contents, and external effects such as HTTP calls. Execution then continues with the next subscriber and returns to the publisher as if nothing went wrong.

Reviewers and authoring agents tend to read "isolated" as "a failed subscriber leaves no trace", so they design isolated events with `var` result parameters or an `IsHandled` switch. A subscriber that sets `IsHandled := true` and then errors makes the publisher skip its default behaviour, even though the subscriber's own work was rolled back.

## Best Practice

Use isolated events for notifications: pass parameters by value and let subscribers act on their own data. When the publisher needs a decision or a result from extensions, publish a normal (non-isolated) event so subscriber errors propagate and the publisher never consumes a half-applied result.

If an isolated event must carry `var` data for compatibility, the publisher must validate the returned values before using them and must not let a returned flag bypass required logic.

See sample: [`isolated-event-rollback-does-not-undo-var-parameters.good.al`](isolated-event-rollback-does-not-undo-var-parameters.good.al).

## Anti Pattern

An event declared with `Isolated = true` whose signature includes `var IsHandled`, a `var` result value, or a `var` record the publisher reads afterwards, where the publisher changes its behaviour based on those values. A failing subscriber can leave them modified while its database writes are rolled back, so the publisher acts on a decision nobody completed.

Changing the `Isolated` flag of an event that has already shipped is a separate contract problem covered by [do-not-change-shipped-event-attribute-flags](do-not-change-shipped-event-attribute-flags.md); this article is about the design of new isolated events.

See sample: [`isolated-event-rollback-does-not-undo-var-parameters.bad.al`](isolated-event-rollback-does-not-undo-var-parameters.bad.al).

## References

[Isolated events in AL, Rollback](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-events-isolated#rollback): only Modify/Delete/Insert on normal tables are rolled back; HTTP calls, variable changes, and single-instance codeunit members are not, and a `var` integer modified by a failing subscriber keeps its change.
