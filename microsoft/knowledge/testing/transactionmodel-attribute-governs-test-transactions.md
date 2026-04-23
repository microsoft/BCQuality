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

`[TransactionModel(...)]` declares how a test method interacts with the database's write transaction. The attribute applies only to methods inside a codeunit with `SubType = Test` and takes one of three values: `AutoRollback`, `AutoCommit`, or `None`. The choice must match the code being exercised — in particular, whether that code calls `Commit()`. Per the platform reference, "if the code that you test includes calls to the COMMIT Method, then set the TransactionModel property on the test method to AutoCommit." Applying `AutoRollback` to a test that drives code which calls `Commit` produces a runtime error on the first Commit, not a meaningful assertion failure — the test does not complete, and the reviewer sees an infrastructure error instead of a business-logic verdict.

## Best Practice

Default to `AutoRollback`: it opens a write transaction at the start of the test, runs the test body, and rolls back at the end, leaving the database in its original state. Pick `AutoCommit` only when the code under test genuinely calls `Commit` — posting routines, job-queue handlers, integration flows — and pair that test's codeunit with a `TestIsolation`-enabled test runner so committed changes are reverted at a higher scope. Pick `None` only for read-only tests or tests that drive UI code without writing from the test method itself, for example tests that validate calculation formulas or read-only projections.

See sample: `transactionmodel-attribute-governs-test-transactions.good.al`.

## Anti Pattern

Applying `AutoRollback` to every test method without checking whether the tested business logic calls `Commit`. The test throws at the first Commit, leaving no verdict on the behavior it intended to verify; in a CI run this looks like a flake or a setup bug, not a specification mismatch. The mirror-image anti-pattern is defaulting to `AutoCommit` across the suite "to avoid the error" — without a `TestIsolation` runner this permanently dirties the test database between runs and produces order-dependent test outcomes.

See sample: `transactionmodel-attribute-governs-test-transactions.bad.al`.
