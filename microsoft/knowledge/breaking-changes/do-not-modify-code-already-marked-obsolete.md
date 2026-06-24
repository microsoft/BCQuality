---
bc-version: [all]
domain: breaking-changes
keywords: [obsolete, clean-flag, conditional-compilation, deprecation, replacement, do-not-extend]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not build on code already marked obsolete

## Description

A member carrying `[Obsolete]`, or wrapped in a `#if not CLEANxx` conditional-compilation block, is already scheduled for deletion — the `CLEANxx` symbol is flipped on in a future release to strip that code out. Adding logic, raising new events, or taking fresh dependencies on such a member ties live behavior to something the platform is about to remove. When the deprecation completes, everything layered on top breaks. The obsolete marker is a one-way signal: it means "migrate off," never "safe to extend." LLMs frequently edit whatever procedure is nearest to the change, including obsolete ones, and add `#if not CLEANxx` branches without understanding that the block is transient.

## Best Practice

Leave obsolete members exactly as they are and implement against the current, supported replacement. New logic — a surcharge calculation, an event publisher, a hook — belongs on the live API (`GetUnitPrice`), never inside the deprecated `GetPrice` or behind a `#if not CLEAN25` guard. If the replacement does not yet exist, create it as a first-class member and build there. The obsolete code should only shrink over time, not accrete new behavior.

See sample: `do-not-modify-code-already-marked-obsolete.good.al`.

## Anti Pattern

Adding a surcharge calculation inside the `[Obsolete]` `GetPrice` procedure, or behind a `#if not CLEAN25` block, so the new behavior is wired to code that will be removed when `CLEAN25` is enabled. Detection: new statements, event declarations, or dependencies introduced inside an `[Obsolete]`-marked member or a `#if not CLEANxx` region. Move the logic onto the supported replacement instead.

See sample: `do-not-modify-code-already-marked-obsolete.bad.al`.
