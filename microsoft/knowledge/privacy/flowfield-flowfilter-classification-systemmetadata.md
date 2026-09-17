---
bc-version: [all]
domain: privacy
keywords: [flowfield, flowfilter, data-classification, systemmetadata, calculated]
technologies: [al]
countries: [w1]
application-area: [all]
---

# FlowFields and FlowFilters are classified `SystemMetadata` automatically

## Description

`FlowField` and `FlowFilter` are not stored fields — a FlowField is computed from a CalcFormula at read time and a FlowFilter is a transient filter scoped to the record variable. Because nothing is ever written to the database for these fields, the platform automatically classifies them as `DataClassification = SystemMetadata` and AL does not require — or expect — the developer to set `DataClassification` on them. A FlowField that surfaces PII (e.g., a sum or lookup over a `CustomerContent` table) is still `SystemMetadata` at the FlowField level; the privacy classification lives on the underlying stored field that the CalcFormula references.

## Best Practice

Do not declare `DataClassification` on `FieldClass = FlowField` or `FieldClass = FlowFilter` fields — the inherited `SystemMetadata` is correct and the property is redundant. If a FlowField exposes sensitive data, ensure the underlying source field has the right `DataClassification`; that is where the platform reads classification from for GDPR and telemetry purposes.

See sample: [`flowfield-flowfilter-classification-systemmetadata.good.al`](flowfield-flowfilter-classification-systemmetadata.good.al).

## Anti Pattern

Flagging a FlowField for "missing `DataClassification`" or trying to override it to `CustomerContent` because the formula references customer data. The platform's automatic `SystemMetadata` value is the documented, intentional behavior for non-stored fields; overriding it adds nothing and misrepresents the field as if it were stored.
