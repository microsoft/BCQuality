# CURABIS MCP: FlowFields on API Pages Must Be CalcFields'd

## Core Principle

FlowFields on API pages return empty or zero unless explicitly calculated. Every FlowField exposed on a `PageType = API` page must be called via `CalcFields` in the `OnAfterGetRecord` trigger — otherwise the OData response will contain empty values regardless of what the underlying data contains.

## Why This Happens

FlowFields are not stored in the database. Business Central only calculates them on demand. Regular pages trigger calculation automatically as part of the page rendering pipeline. API pages do not — the agent or external consumer receives the raw stored (empty) value.

## Requirements

- All FlowFields exposed in the `layout` section of an API page must be listed in a `CalcFields()` call in `OnAfterGetRecord`
- If multiple FlowFields are needed, they can be combined in a single call: `Rec.CalcFields(Field1, Field2)`
- Stored fields (non-FlowField) do not need CalcFields

## Example

```al
trigger OnAfterGetRecord()
begin
    Rec.CalcFields("Elapsed time (Chargeable)", "Customer Name");
end;
```

## Verification

When reviewing an API page, identify every field bound to a FlowField source expression. Confirm each appears in the `OnAfterGetRecord` CalcFields call. Any FlowField missing from CalcFields is a defect — it will silently return empty to the MCP consumer.

## Related Rule

CURABIS-MCP-002 — Stored derived fields must be recalculated in OnAfterGetRecord, not exposed directly.
