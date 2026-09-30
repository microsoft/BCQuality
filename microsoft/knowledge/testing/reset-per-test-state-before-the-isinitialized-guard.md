---
bc-version: [all]
domain: testing
keywords: [initialize, isinitialized, library-test-initialize, ontestinitialize, library-variable-storage, library-setup-storage, test-fixture, test-codeunit]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reset per-test state before the IsInitialized guard

## Description

Standard Business Central test codeunits call a local `Initialize` procedure at the start of every test method. Global variables in a test codeunit keep their values between the codeunit's test methods, so a Boolean such as `IsInitialized` lets `Initialize` run expensive shared setup only once. The procedure therefore has two parts with different lifetimes: work that must run before **every** test, and one-time setup behind the guard. If per-test reset is placed after the guard, it runs only for the first test. Values left in `Library - Variable Storage` by a failed test, or setup records a test changed, then leak into later tests, which pass or fail depending on execution order.

## Best Practice

Call `Initialize()` as the first statement of every test method. Inside it, keep this order, which the Base Application tests follow:

1. Per-test work, before the guard: raise `"Library - Test Initialize".OnTestInitialize`, call `LibraryVariableStorage.Clear()`, and call `LibrarySetupStorage.Restore()` when setup tables were saved.
2. `if IsInitialized then exit;`
3. One-time work: raise `OnBeforeTestSuiteInitialize`, create the shared fixture and setup values, set `IsInitialized := true`, save the setup tables that tests may change (for example `LibrarySetupStorage.SaveSalesSetup()`), and raise `OnAfterTestSuiteInitialize`.

Create data that a single test changes inside that test, not in the shared fixture. Base Application suites also commit after the one-time setup so the shared fixture survives each test's transaction; whether that commit is valid depends on the test transaction model and runner isolation, see [`transactionmodel-attribute-governs-test-transactions.md`](transactionmodel-attribute-governs-test-transactions.md) and [`testisolation-belongs-on-the-test-runner.md`](testisolation-belongs-on-the-test-runner.md).

A test codeunit with no shared setup and no queued values doesn't need an `Initialize` procedure. Don't report its absence on its own.

See sample: [`reset-per-test-state-before-the-isinitialized-guard.good.al`](reset-per-test-state-before-the-isinitialized-guard.good.al).

## Anti Pattern

`if IsInitialized then exit;` as the first statement of `Initialize`, followed by `LibraryVariableStorage.Clear()`, `LibrarySetupStorage.Restore()`, or other reset calls that are then skipped for every test after the first. A related defect is a test method in a codeunit that uses the pattern but doesn't call `Initialize()`, so it runs with whatever state the previous test left. Detection signal: in a `Subtype = Test` codeunit, a reset call placed after the `IsInitialized` exit, or a `[Test]` procedure that uses shared globals or queued values without first calling `Initialize()`.

See sample: [`reset-per-test-state-before-the-isinitialized-guard.bad.al`](reset-per-test-state-before-the-isinitialized-guard.bad.al).

## References

- [BCApps: `Initialize` in the ERM Sales Document tests](https://github.com/microsoft/BCApps/blob/4abbb8ff848cdcb4e1187fc7a3e2da0612dd0d2b/src/Layers/W1/Tests/ERM-Sales/ERMSalesDocument.Codeunit.al)
- [BCApps: Library - Test Initialize events](https://github.com/microsoft/BCApps/blob/4abbb8ff848cdcb4e1187fc7a3e2da0612dd0d2b/src/Layers/W1/Tests/ApplicationTestLibrary/LibraryTestInitialize.Codeunit.al)
- [BCApps: Library - Setup Storage](https://github.com/microsoft/BCApps/blob/4abbb8ff848cdcb4e1187fc7a3e2da0612dd0d2b/src/Layers/W1/Tests/ApplicationTestLibrary/LibrarySetupStorage.Codeunit.al)
- [Testing the application](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-testing-application)
