---
bc-version: [all]
domain: performance
keywords: [setloadfields, filter, field-exclusion, index]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Omit filter-only fields from SetLoadFields

> **Seed article.** Ported from BC Code Intelligence to seed the community corpus. Community contributors are invited to expand or refine.

## Description

Fields used only in `SetRange` and `SetFilter` do their work at the database level using indexes; their values never need to be loaded into AL memory for the filter to apply. Listing such fields in `SetLoadFields` costs the transfer and memory footprint of every row's value for no functional benefit. Distinguishing filter-only fields from processing fields keeps the loaded column set as narrow as the iterating code actually reads.

## Best Practice

Include in `SetLoadFields` exactly the fields the iterating code reads. Fields referenced only in `SetRange`/`SetFilter` stay out of the list — filtering continues to work correctly because the database uses the index. Treat the audit as "what does the `repeat…until` block touch?" rather than "what does this procedure mention?".

See sample: `omit-filter-only-fields-from-setloadfields.good.al`.

## Anti Pattern

Listing every field the procedure mentions in `SetLoadFields`, including date-range or status fields that appear only in filters. The loaded record now carries per-row values for columns the processing body never reads, inflating memory and network cost without changing any behavior.

See sample: `omit-filter-only-fields-from-setloadfields.bad.al`.
