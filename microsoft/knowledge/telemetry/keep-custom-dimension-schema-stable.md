---
bc-version: [17..]
domain: telemetry
keywords: [customdimensions, dimension-key, schema, pascalcase, kql, breaking-change]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Treat custom dimension keys as a stable telemetry schema

## Description

Business Central prefixes AL custom-dimension keys with `al` in Application Insights, so an AL key named `Result` becomes `alResult`. Microsoft guidance treats telemetry definitions as an API: changing or removing a custom dimension can break dashboards and alerts. PascalCase keys without spaces also compose cleanly in KQL; spaces force awkward bracket access and make queries harder to maintain.

## Best Practice

Choose stable PascalCase keys such as `Operation`, `Result`, and `RecordCount`. Keep the key set and meaning stable for a shipped event ID; add a new event ID or coordinate a schema migration when the meaning must change. Privacy guidance separately governs whether a dimension value may contain customer data.

See sample: `keep-custom-dimension-schema-stable.good.al`.

## Anti Pattern

Keys such as `'order no'` or `'result_code'`, or renaming/removing a key while retaining the same shipped event ID. A naming-only issue is advisory; changing an existing event's schema is the material compatibility defect. New keys on a new event ID are not a breaking change.

See sample: `keep-custom-dimension-schema-stable.bad.al`.
