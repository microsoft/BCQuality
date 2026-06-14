---
bc-version: [all]
domain: testing
keywords: [initialize, isinitialized, test-isolation, test-pollution, test-setup, libraryvariablestorage]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Test codeunit Initialize function must use an IsInitialized guard

## Description

Every test codeunit should have a single `Initialize()` procedure called as the first statement in each `[Test]` function. Without an `IsInitialized` boolean guard, setup runs before every test — which is slow and causes side effects. Without `Initialize()` at all, setup logic gets duplicated across test functions and shared state bleeds between tests.

## Best Practice

Declare `IsInitialized` as a boolean at codeunit scope. In `Initialize()`, call `LibraryVariableStorage.Clear()` first — it must run on every test call regardless of the guard. Then check `if IsInitialized then exit`. Run one-time setup after the guard, set `IsInitialized := true`, then call `Commit()`. Call `Initialize()` as the first statement in every `[Test]` procedure.

See sample: `initialize-function-pattern.good.al`.

## Anti Pattern

Duplicating setup logic directly inside each test function, or calling `Initialize()` without the `IsInitialized` guard. Duplicated setup diverges silently when changed in one place. Omitting `LibraryVariableStorage.Clear()` leaves stale message handlers from prior tests, causing unrelated tests to fail intermittently.

See sample: `initialize-function-pattern.bad.al`.
