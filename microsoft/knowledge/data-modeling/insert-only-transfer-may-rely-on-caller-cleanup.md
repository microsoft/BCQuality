---
bc-version: [all]
domain: data-modeling
keywords: [transfer, cleanup, deleteall, onvalidate, caller, stale-rows, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# An insert-only transfer routine may rely on cleanup its caller already performed

## Description

A routine that copies rows from a template table into a target table — a `TransferX` procedure filling comment, dimension, or attribute lines from a standard-task or template record — is frequently written as filter-and-insert with no `DeleteAll` of its own. That is not automatically a stale-row or duplicate-primary-key defect. In the common AL shape, the field's `OnValidate` trigger first calls a sibling cleanup procedure that clears the same filtered range, then calls the transfer. By the time `Insert` runs, the target range is guaranteed empty, so the transfer has nothing to clean up and adding a second `DeleteAll` inside it would be redundant.

Deciding whether a missing cleanup is real therefore requires reading the caller, not just the routine in the diff. The relevant question is whether every path that reaches the transfer clears the target range first — not whether the transfer clears it itself.

## Best Practice

Before reporting a transfer or copy routine for missing cleanup, trace its call sites. If the callers in scope invoke a cleanup procedure that clears the same filtered range immediately beforehand — typically in the same `OnValidate` trigger or the same routine — the insert-only transfer is correct and must not be flagged for stale rows, duplicate keys, or a missing `DeleteAll`. Raise the finding only when a reachable call path inserts into a range that was not cleared, or when the cleanup filters a different range than the insert writes to.

## Anti Pattern

Reporting an insert-only transfer as a stale-row or duplicate-key risk on the strength of the routine body alone, when the trigger that calls it already ran the cleanup. The mirror-image mistake is waving through a transfer whose caller clears a *different* filter range than the one the transfer inserts into, or one reachable from a path with no cleanup at all — those are genuine defects.
