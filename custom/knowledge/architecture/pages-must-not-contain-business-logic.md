---
bc-version: [all]
domain: architecture
keywords: [page, trigger, onaction, modify, codeunit, logic]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

In CURABIS codebases, pages are pure presentation. Business logic, calculations,
validations, and record modifications belong in codeunits — not in page triggers
or actions. This is stricter than the general BC guidance and applies to all
CURABIS PTE apps.

A page procedure that calculates a value and assigns it to a field, calls
`Rec.Modify()` directly, or implements business rules is an architecture violation
even if it compiles.

**Exceptions:**
- Setup pages may read and write their own setup record directly.
- The designated "Run Conversion" page may call the conversion codeunit directly.

## Anti Pattern

```al
// WRONG: calculation and Modify in a page action
trigger OnAction()
begin
    Rec."Total Amount" := Rec.Quantity * Rec."Unit Price";
    Rec."VAT Amount" := Rec."Total Amount" * 0.25;
    Rec.Modify();
end;
```

```al
// WRONG: validation logic in page trigger
trigger OnValidate()
begin
    if Rec.Quantity < 0 then
        Error('Quantity cannot be negative');
    Rec."Total Amount" := Rec.Quantity * Rec."Unit Price";
end;
```

## Best Practice

```al
// CORRECT: page delegates to codeunit
trigger OnAction()
begin
    SVManagement.RecalculateLine(Rec);
end;
```

```al
// CORRECT: validation belongs in table or codeunit
trigger OnValidate()
begin
    SVManagement.ValidateAndRecalculate(Rec);
end;
```

The codeunit owns the logic. The page owns the presentation.
