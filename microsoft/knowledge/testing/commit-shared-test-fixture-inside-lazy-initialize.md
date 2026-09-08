---
bc-version: [all]
domain: testing
keywords: [initialize, isinitialized, shared-fixture, commit, autocommit, asserterror, testisolation, lazy-initialization]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Commit shared fixture data created inside a lazy Initialize(), or later tests lose it

## Description

A test method with no `[TransactionModel(...)]` attribute defaults to `AutoCommit` (see `transactionmodel-attribute-governs-test-transactions.md`): a method that completes without error commits automatically at its own boundary, with no explicit `Commit()` needed. So a lazy/shared `Initialize()` — guarded by an `IsInitialized` flag, creating master/setup data once to avoid repeating expensive setup across many `[Test]` methods — does not need `Commit()` just to survive into the next test method; under the default model it already will. (Declaring `[TransactionModel(AutoRollback)]` instead is not compatible with this pattern at all: `AutoRollback` assumes the code under test never commits, and a `Commit()` call under it raises a runtime error.)

What an early `Commit()` inside `Initialize()` actually guards against is the test method's *own later, deliberate* rollback — the BCApps cleanup idiom of ending a test with `asserterror Error(SomeLabel)` to undo demo-data mutations that method made, so the run doesn't permanently dirty the database. Per the documented `Codeunit.Run` transaction semantics, changes are committed at the end of an execution "unless an error occurs" — an unhandled error rolls back whatever wasn't already committed. `Commit()` closes out the fixture's own transaction immediately, so it is unaffected by whatever the rest of that method does afterward, including that end-of-test error. Without the early `Commit()`, the same deliberate rollback wipes out the fixture too, even though `IsInitialized` still reads `true` on the next test, since it's a plain variable, not persisted data. BCApps' `codeunit 134915 "ERM Online Mapping Setup"` shows exactly this shape: no `TransactionModel` attribute, `Commit()` inside a lazy `Initialize()`, and the test itself ends with `asserterror Error(RollBackMessage)`.

Protecting the fixture from that same-method rollback is necessary but not sufficient for the fixture to reach a *later* test method — that also depends on the executing test runner's `TestIsolation`. Under `Disabled` (the property's own documented default) or `Codeunit` (used by BCApps' own `TestRunner`, `CLITestRunner`, and `SnapTestRunner` codeunits), nothing rolls back until the whole test codeunit finishes, so the already-committed fixture survives across every method run before then. Under `Function`, the runner rolls back all database changes — explicitly including ones already committed via `Commit()` — after every single test method; no amount of committing inside `Initialize()` makes a fixture shared across methods survive that regime, because the whole premise of a lazy, once-per-codeunit fixture doesn't hold when every method is isolated from every other.

## Best Practice

When a test method's own cleanup relies on ending in a deliberate error to roll back its scratch changes, call `Commit()` once, inside the lazy `Initialize()` guard, right after the shared fixture is created — before that cleanup-triggering error can run. This pattern only delivers a fixture shared across test methods when the executing runner's `TestIsolation` is `Disabled` or `Codeunit`; do not recommend it, or pair it with, a `Function`-isolated runner — that configuration undoes the committed fixture after every method regardless.

See sample: `commit-shared-test-fixture-inside-lazy-initialize.good.al`.

## Anti Pattern

A shared `Initialize()` guarded by `IsInitialized` that creates fixture records without committing, in a test method that ends with a deliberate `asserterror Error(...)` to undo its own scratch changes, run under a `Disabled`- or `Codeunit`-isolated test runner. That rollback also erases the never-committed fixture; the next test still finds `IsInitialized = true` but the rows it depends on are gone. (Under a `Function`-isolated runner the fixture is lost regardless of `Commit()`, for the unrelated reason above — that is a runner-configuration problem, not this anti-pattern.)

See sample: `commit-shared-test-fixture-inside-lazy-initialize.bad.al`.

## Source

The shared/lazy `Initialize()` pattern and its `Commit()` call are drawn from Luc van Vugt's "Let's talk about Shared Fixture and how to profit from this with the Dynamics NAV Test Toolkit": https://www.fluxxus.nl/index.php/bc/let39s-talk-about-shared-fixture-and-how-to-profit-from-this-with-the-dynamics-nav-test-toolkit/. That post shows the `Commit()` call in its `Initialize()` example but does not explain the transaction mechanics behind it; the `AutoCommit`-default, `Codeunit.Run`-error, and `TestIsolation`-level analysis above is this article's own, verified independently against Microsoft's TransactionModel/TestIsolation documentation and BCApps' `codeunit 134915 "ERM Online Mapping Setup"` source, not taken from the post.
