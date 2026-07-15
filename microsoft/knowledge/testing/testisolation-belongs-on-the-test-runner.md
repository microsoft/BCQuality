---
bc-version: [all]
domain: testing
keywords: [testisolation, testrunner, autocommit, commit, rollback, test-order, database-state]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Configure TestIsolation on the test runner

## Description

`TestIsolation` is a property of a `Subtype = TestRunner` codeunit, not of the test codeunit being executed. Its default is `Disabled`. `Codeunit` rolls back database changes after each test codeunit and `Function` after each test method, including changes that the code under test explicitly committed. Without runner isolation, an `AutoCommit` test can leave data behind and make later tests order-dependent.

## Best Practice

Run independent suites with `TestIsolation = Codeunit` or `Function`, choosing the narrowest boundary the runner supports. Pair this with the appropriate method-level `TransactionModel`: `AutoCommit` permits code under test to commit, while runner isolation still restores the database afterward. Keep isolation disabled only for an intentionally shared-state suite whose ordering and cleanup are explicit.

See sample: `testisolation-belongs-on-the-test-runner.good.al`.

## Anti Pattern

An `AutoCommit` test exercises committed writes under a test runner that omits `TestIsolation` or sets it to `Disabled`, then assumes the database is restored automatically. This article owns runner-level rollback; `transactionmodel-attribute-governs-test-transactions.md` separately owns the method attribute.

See sample: `testisolation-belongs-on-the-test-runner.bad.al`.
