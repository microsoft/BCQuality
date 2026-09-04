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

For every major business flow the extension adds, create a matching `BCPT*` scenario codeunit: `SingleInstance = true`, implementing `"BCPT Test Param. Provider"`, wrapping the operation under test in `BCPTTestContext.StartScenario()` / `EndScenario()`, and building its own test data in a local `InitTest()` procedure rather than depending on hardcoded records. Give each distinct step its own named scenario so a regression in one step doesn't hide inside a coarser measurement.

See sample: `bcpt-scenarios-must-be-app-specific.good.al`.

## Anti Pattern

A PerformanceTest app whose only scenario codeunits are copies of Microsoft's shipped samples (creating a standard sales order, opening the standard customer list) tests the platform, not the extension. Any regression in the extension's own posting logic, calculations, or pages goes unmeasured and unnoticed.

See sample: `bcpt-scenarios-must-be-app-specific.bad.al`.
