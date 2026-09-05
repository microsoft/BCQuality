---
bc-version: [all]
domain: testing
keywords: [initialize, isinitialized, shared-fixture, commit, autorollback, lazy-initialization]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Commit shared fixture data created inside a lazy Initialize(), or later tests lose it

## Description

A test codeunit that creates master/setup data once, guarded by an `IsInitialized` flag, to avoid repeating expensive setup across many `[Test]` methods depends on that data surviving into every later test. Each `[Test]` method runs under `AutoRollback` by default, so data inserted during the first test's call to `Initialize()` rolls back at the end of that test. `IsInitialized` is a variable, not persisted data, so it still reads `true` on the next test — but the fixture rows it points to are already gone.

## Best Practice

Call `Commit()` at the end of a lazy/shared `Initialize()` procedure, once the shared fixture data is created, so it survives past the first test's rollback boundary. Pair this with a `TestIsolation`-enabled test runner so the committed fixture is still cleaned up at the end of the full run.

See sample: `commit-shared-test-fixture-inside-lazy-initialize.good.al`.

## Anti Pattern

A shared `Initialize()` guarded by `IsInitialized` that creates fixture records but never commits. The first test that runs it passes; every later test in the same codeunit either fails to find the fixture data or silently re-triggers setup logic that `IsInitialized` was meant to skip.

See sample: `commit-shared-test-fixture-inside-lazy-initialize.bad.al`.
