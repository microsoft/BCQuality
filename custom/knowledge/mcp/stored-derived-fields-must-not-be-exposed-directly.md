# CURABIS MCP: Stored Derived Fields Must Be Recalculated in OnAfterGetRecord

## Core Principle

A stored field whose value is derived from other fields via `OnValidate` triggers can be stale. When the source data changes (e.g., new time entries posted), the stored derived field is not updated automatically — it only recalculates when a specific trigger fires. Exposing such a field directly via an API page returns a value that may be hours, days, or weeks out of date.

## Pattern to Avoid

```al
// WRONG: Exposes the stored snapshot — may be stale
field(timeLeft; Rec."Time left") { }
```

`"Time left"` is recalculated only when `"Estimated time"` is validated. If new time entries are posted, the stored value does not update.

## Correct Pattern

Recalculate in `OnAfterGetRecord` using a page variable:

```al
trigger OnAfterGetRecord()
begin
    Rec.CalcFields("Elapsed time (Chargeable)");
    TimeLeftCalc := Rec."Estimated time" - Rec."Elapsed time (Chargeable)";
end;

var
    TimeLeftCalc: Decimal;

// In layout:
field(timeLeft; TimeLeftCalc) { }          // live value
field(elapsedTime; Rec."Elapsed time (Chargeable)") { }  // source FlowField
```

## Requirements

- Identify stored fields whose value is computed from other fields via triggers
- Do not expose them directly in API pages
- Recalculate from the authoritative source (FlowField or live query) in `OnAfterGetRecord`
- Expose both the recalculated result and the source FlowField so the consumer can verify

## Verification

Inspect the source table for any field with `FieldClass = Normal` whose value is set inside an `OnValidate` trigger on another field. If that field is exposed on an API page, verify it is recalculated in `OnAfterGetRecord` rather than read from `Rec` directly.
