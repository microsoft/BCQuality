---
bc-version: [all]
domain: testing
keywords: [testing, test-data, random, library, any]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Generate Test Data Programmatically, Never Assume Existing Records

> Contributions welcome — open a PR to refine or extend this article.

## Description

An AL test suite should assume an empty database. Test data must be created programmatically inside the test rather than assuming a specific code, number, or name already exists in the environment — a hardcoded lookup against an assumed-existing record makes the test fail for reasons unrelated to the code under test. Every mandatory field on a created record also needs a value that respects its declared length; a partial setup that merely passes validation is not sufficient.

## Best Practice

Use the standard library codeunits (`Library - ERM`, `Library - Inventory`, `Library - Sales`, `Library - Utility`) to create records with collision-free random values, and fill every mandatory field with randomized, correctly-sized data. Reserve hardcoded values for tests that validate an external contract itself — a fixed JSON schema, an EDIFACT message, a counterparty code — where the hardcoded value documents the specification rather than arbitrary test logic.

See sample: `test-data-must-be-random-and-complete.good.al`.

## Anti Pattern

Looking up a record assumed to already exist (a hardcoded payment method or customer number) instead of creating it, or leaving mandatory fields empty or underfilled because validation happens to allow it.

See sample: `test-data-must-be-random-and-complete.bad.al`.
