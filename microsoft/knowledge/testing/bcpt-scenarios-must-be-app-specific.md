---
bc-version: [all]
domain: testing
keywords: [bcpt, performance-test, scenarios, app-specific, regression]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Include app-specific scenarios in a PerformanceTest app's BCPT suite

## Description

A PerformanceTest app that ships with only the generic Microsoft BCPT samples (creating sales orders, purchase orders, posting item journals) measures Business Central's own baseline performance, not the extension it was built to test. Those samples are starting points, not coverage. Without a scenario that exercises the extension's own business flow — its own codeunits, its own FlowFields, its own page rendering — a performance regression introduced by the extension has no test that would ever detect it.

## Best Practice

For every major business flow the extension adds, create a matching `BCPT*` scenario codeunit implementing `"BCPT Test Param. Provider"`, building its own test data in a local `InitTest()` procedure rather than depending on hardcoded records. Beyond that shared shape, the interface details are context-dependent, not fixed requirements: most of Microsoft's own shipped BCPT samples declare `SingleInstance = true`, but `codeunit "BCPT Create Customer"` does not, relying instead on `OnRun` calling `InitTest()` unconditionally every run. Likewise, wrapping the operation under test in `BCPTTestContext.StartScenario()` / `EndScenario()` is a real, available pattern for splitting one codeunit's run into several separately measured steps — useful when a regression in one step should not hide inside a coarser, whole-`OnRun` measurement — but it is not what every sample does; `"BCPT Create Customer"` measures its entire `OnRun` as a single implicit scenario and never calls `StartScenario`/`EndScenario` at all. Choose per-step scenarios when step-level granularity matters to the flow being tested; otherwise a single measured `OnRun` is a legitimate, simpler choice.

See sample: `bcpt-scenarios-must-be-app-specific.good.al`.

## Anti Pattern

A PerformanceTest app whose only scenario codeunits are copies of Microsoft's shipped samples (creating a standard sales order, opening the standard customer list) tests the platform, not the extension. Any regression in the extension's own posting logic, calculations, or pages goes unmeasured and unnoticed.

See sample: `bcpt-scenarios-must-be-app-specific.bad.al`.
