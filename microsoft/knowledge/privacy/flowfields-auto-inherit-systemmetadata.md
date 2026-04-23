---
bc-version: [all]
domain: privacy
keywords: [flowfield, flowfilter, dataclassification, systemmetadata, default]
technologies: [al]
countries: [w1]
application-area: [all]
---

# FlowFields and FlowFilters automatically inherit DataClassification SystemMetadata

## Description

FlowFields and FlowFilters are virtual — they carry no stored data of their own, and their values are computed on demand from the source table the CalcFormula references. The platform classifies them as SystemMetadata automatically and does not require (or respect) a per-field DataClassification declaration. Flagging a FlowField as missing DataClassification, or as under-classified because the computed value may be CustomerContent, is a false positive: the underlying source field carries the classification that matters, and that is what telemetry and compliance tooling inspects.

## Best Practice

Leave DataClassification off FlowFields and FlowFilters. If the computed value is sensitive, the fix is to ensure the source table's field has the correct classification. Verify source-field classification rather than trying to re-classify the computed view.

## Anti Pattern

Reporting "missing DataClassification" on a FlowField, or attempting to set a FlowField's DataClassification to CustomerContent because the SUM aggregates a sensitive amount. The declaration has no effect; the platform uses the source-field classification.
