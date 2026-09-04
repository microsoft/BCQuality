---
bc-version: [all]
domain: testing
keywords: [feature, scenario, given, when, then, tags, bdd, atdd, comments]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Tag test codeunits with FEATURE, SCENARIO, GIVEN, WHEN, and THEN comments

## Description

Test codeunits are easier to trust and to review when they carry a four-level comment structure taken from Behaviour-/Acceptance-Test-Driven Development: `[FEATURE]` once at the top of the codeunit naming the functional area under test, `[SCENARIO]` above each test procedure stating one falsifiable business claim in plain language, and `[GIVEN]`/`[WHEN]`/`[THEN]` marking the precondition, action, and assertion inside the test body. Without these tags a test procedure is an opaque block of AL that only reveals its intent by being read line by line; a reviewer or product owner cannot scan a codeunit and know what business behaviour it covers.

## Best Practice

Put `[FEATURE]` as a comment before the codeunit's opening brace, naming the domain rather than the object. Put `[SCENARIO]` immediately above each `[Test]` attribute, describing the scenario in business language that complements — not duplicates — the procedure name. Inside the body, mark the precondition setup as `[GIVEN]`, the single action under test as `[WHEN]`, and the assertions as `[THEN]`. The procedure name stays the machine-readable identity shown in test-runner output; the `[SCENARIO]` comment stays the human-readable one. Neither replaces the other.

See sample: `test-feature-scenario-tags.good.al`.

## Anti Pattern

A test procedure with no `[FEATURE]`/`[SCENARIO]`/`[GIVEN]`/`[WHEN]`/`[THEN]` structure, setup mixed freely with assertions, and a procedure name like `Test1` that says nothing about what is being verified. Nothing in the codeunit tells a reader what business rule it exists to protect.

See sample: `test-feature-scenario-tags.bad.al`.
