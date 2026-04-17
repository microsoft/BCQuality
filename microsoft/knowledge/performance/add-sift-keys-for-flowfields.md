---
bc-version: [26..28]
domain: performance
keywords: [sift, sumindexfields, flowfield, key, aa0232]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Add SIFT keys for FlowField aggregations

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

CodeCop rule AA0232 checks that FlowFields backed by CalcSums or aggregation CalcFormula are supported by a key whose SumIndexFields include the summed field and whose key prefix matches the formula's filter fields. Without a SIFT key the platform falls back to a full aggregation on every read — typically invisible in development and catastrophic in production.

## Best Practice

For each Sum-style FlowField, ensure the source table has a key whose leading fields match the FlowField's CalcFormula WHERE clause and whose SumIndexFields list includes the summed field. Table extensions adding new FlowFields are responsible for adding the supporting key.

See sample: `add-sift-keys-for-flowfields.good.al`.

## Anti Pattern

Declaring a FlowField on a hot table without checking whether a supporting SIFT key exists ships a latent scan into every list page and report that touches the field.

