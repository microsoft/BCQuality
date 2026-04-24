---
bc-version: [all]
domain: performance
keywords: [test-framework, bulk-insert, performance-test, benchmark, insert]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Uninstall the test framework to measure insert performance

## Description

Business Central's server uses a bulk insert optimization that batches multiple row inserts into a single SQL round-trip when conditions allow. When the test framework is installed on the environment, that optimization is disabled — inserts fall back to one SQL statement per row. The behavior is a side-effect of how the test framework instruments AL execution and applies whether or not any test is actually running.

For functional tests this is invisible; for performance measurement it is catastrophic. A benchmark that inserts ten thousand rows with the test framework present reports a number that has nothing to do with production, because production will not run in row-by-row mode. Treating the measurement as a real baseline produces conclusions that are wrong by a large constant factor.

The same caveat applies to Update and Delete paths where bulk optimizations exist — the test framework's presence suppresses them.

## Best Practice

Before running any insert, update, or delete throughput benchmark — whether via the Performance Toolkit, a hand-rolled harness, or `SessionInformation` assertions — uninstall the test framework from the target environment. Re-install it only for functional test runs. Document this step in the benchmark procedure so future measurements are comparable.

## Anti Pattern

A performance regression report comparing two builds on a sandbox that has the test framework installed. Both numbers are row-by-row timings; the ratio between them may be meaningful, but neither number reflects production, and any absolute throughput claim derived from the run is wrong.
