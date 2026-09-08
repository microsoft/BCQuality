---
bc-version: [all]
domain: testing
keywords: [transactionmodel, attribute, test, autorollback, autocommit, testisolation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Match TransactionModel to the commit behavior of the code under test

## Description

`[TransactionModel(...)]` declares how a test method interacts with the database's write transaction. The attribute applies only to methods inside a codeunit with `SubType = Test` and takes one of three values: `AutoRollback`, `AutoCommit`, or `None`. **`AutoCommit` is the documented default** — a test method with no `[TransactionModel(...)]` attribute at all runs under `AutoCommit`, not `AutoRollback` and not `None` (Microsoft's TransactionModel property reference states this explicitly: "AutoCommit is the default value"). The "a call to `Commit` produces a runtime error" behavior is specific to the *explicitly declared* `AutoRollback` attribute. BCApps' own canonical pattern for a lazily-initialized shared fixture (see `codeunit 134915 "ERM Online Mapping Setup"`) declares no `TransactionModel` attribute at all — so it runs under the `AutoCommit` default — calls `Commit()` inside its `Initialize()` helper, and cleans up manually with a deliberate `asserterror Error(...)` at the end rather than relying on automatic rollback; this is a legitimate, common pattern, not a bug. Per the same reference, under `AutoCommit` an error, even one caught by `asserterror`, still rolls back the transaction — but "only to the point at which `Commit` was called" if the code being tested committed first. When a test method *does* declare `AutoRollback` explicitly, the choice must match the code being exercised: per the platform reference, "if the code that you test includes calls to the COMMIT Method, then set the TransactionModel property on the test method to AutoCommit." Applying `AutoRollback` to a test that drives code which calls `Commit` produces a runtime error on the first Commit, not a meaningful assertion failure.

## Best Practice

Leave `[TransactionModel(...)]` undeclared to get the `AutoCommit` default when the codeunit's own tests rely on that default's behavior — for example a lazily-initialized shared fixture that commits once and cleans up its own scratch changes with a manual `asserterror`-based rollback (see `commit-shared-test-fixture-inside-lazy-initialize.md`); do not treat that absence as equivalent to declaring `AutoRollback`. When declaring `[TransactionModel(...)]` explicitly instead, pick `AutoRollback` for a test whose own logic and the code it exercises make no `Commit` call, `AutoCommit` when the code under test genuinely calls `Commit` — posting routines, job-queue handlers, integration flows — and make the test exercise that commit path, and `None` for a read-only test or one that drives UI code without writing from the test method itself. Pair an intentional, suite-wide reliance on `AutoCommit` with a `TestIsolation`-enabled test runner so committed changes are reverted at a higher scope.

See sample: `transactionmodel-attribute-governs-test-transactions.good.al`.

## Anti Pattern

Declaring `[TransactionModel(AutoRollback)]` explicitly on a test method without checking whether the tested business logic calls `Commit`. The test throws at the first Commit, leaving no verdict on the behavior it intended to verify; in a CI run this looks like a flake or a setup bug, not a specification mismatch. The mirror-image anti-pattern is defaulting to `AutoCommit` across the suite "to avoid the error" — without a `TestIsolation` runner this permanently dirties the test database between runs and produces order-dependent test outcomes. Flagging a `Commit()` call in a test method that declares no `TransactionModel` attribute at all is not this anti-pattern — that shape does not error, and is BCApps' own documented pattern for shared lazy fixtures.

See sample: `transactionmodel-attribute-governs-test-transactions.bad.al`.

## Source

The `AutoCommit`-is-default claim and the exact rollback-to-last-`Commit` mechanics are quoted from Microsoft's TransactionModel Property reference: https://learn.microsoft.com/en-us/previous-versions/dynamicsnav-2018-developer/TransactionModel-Property. The current AL [TransactionModel attribute](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/attributes/devenv-transactionmodel-attribute) page describes the same three values but never states a default; this older property reference is the citable source for that fact.
