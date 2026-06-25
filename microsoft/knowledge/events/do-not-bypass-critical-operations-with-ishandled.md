---
bc-version: [all]
domain: events
keywords: [ishandled, critical-operations, posting, data-integrity, ledger, integration-event, safety]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not bypass critical operations with IsHandled

## Description

The IsHandled override pattern lets a subscriber skip the guarded code entirely. A critical operation is one that cannot stand as an independent, self-contained unit — code whose partial execution or omission leaves the system inconsistent (imbalanced ledgers, orphaned documents, gaps in a number series, or skipped permission checks). That is acceptable around a pure, side-effect-free calculation, but dangerous around critical operations — posting, ledger-entry creation, number-series consumption, and referential-integrity or permission validation. Wrapping those in `OnBeforeX(…; var IsHandled); if IsHandled then exit;` lets any subscriber silently suppress them, risking imbalanced ledgers, orphaned documents, skipped permission checks, or duplicated numbers — corruption that surfaces far from the subscriber that caused it. Make the calculation overridable, not the commit: expose the value computation through IsHandled, or offer a regular `OnAfter…` event to adjust results, while the critical work runs unconditionally.

## Best Practice

Scope IsHandled to a safe value-calculation block and run the critical operations unconditionally afterwards; or expose a positive `OnAfter…` event for subscribers to adjust results, rather than a bypass around the commit.

See sample: `do-not-bypass-critical-operations-with-ishandled.good.al`.

## Anti Pattern

An `OnBefore…` IsHandled guard wrapping a posting or ledger routine — `if IsHandled then exit;` around the code that creates ledger entries and updates document status — letting subscribers skip the commit. Detection: an `if IsHandled then exit;` whose skipped body performs posting, ledger writes, number-series consumption, or integrity and permission validation.

See sample: `do-not-bypass-critical-operations-with-ishandled.bad.al`.
