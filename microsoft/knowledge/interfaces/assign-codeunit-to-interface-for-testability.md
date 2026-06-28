---
bc-version: [16..]
domain: interfaces
keywords: [interface, dependency-injection, testability, test-double, codeunit, polymorphism, mocking]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Assign a codeunit to an interface variable for injectable, testable dependencies

## Description

An interface variable can hold any codeunit that `implements` the interface, assigned directly — no enum is required. That is the lever for dependency injection in AL: a consumer depends on the interface, production code injects the real codeunit, and a test injects a lightweight double that returns predictable values. A consumer that instead `var`-declares a concrete `Codeunit` type hardwires the dependency, so a test is forced to exercise the real logic — external calls, posting, and all. Interfaces arrived in Business Central 2020 release wave 1; LLMs still default to concrete codeunit variables and miss the seam that makes code testable.

## Best Practice

Declare the dependency as an `Interface` variable on the consumer and supply the implementation from outside — typically setter injection through a procedure that takes an `Interface` parameter, or a parameter on the entry method. Production passes the real implementation codeunit; a test passes a test-double codeunit that implements the same interface with deterministic behaviour. Because a codeunit assigns to an interface variable directly, no enum or factory is needed for the injectable case. The consumer's logic is then verifiable in isolation.

See sample: `assign-codeunit-to-interface-for-testability.good.al`.

## Anti Pattern

A consumer that declares its dependency as a concrete `Codeunit "..."` variable and calls it directly. The collaborator cannot be substituted, so a unit test either runs the production side effects or cannot cover the consumer at all. Detection signal: a `var` of type `Codeunit "<concrete impl>"` used for a collaborator that has — or could have — an interface, especially one that performs I/O, posting, or external calls. Extract an interface, depend on the interface variable, and inject the implementation.

See sample: `assign-codeunit-to-interface-for-testability.bad.al`.
