---
bc-version: [all]
domain: architecture
keywords: [naming, english, enu, variable, procedure, field, caption, translation, xliff]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

All AL identifiers must be written in English (ENU) regardless of the language
used in conversation with the developer. Translations are handled separately
via XLIFF files — never by writing Danish, German or other language identifiers
in AL source code.

This applies to:
- Variable names
- Procedure names
- Parameter names
- Field names
- Object names (tables, codeunits, pages, enums, reports)
- Enum value names
- Local and global labels (Label data type) — both the identifier and the default text

**Captions and ToolTips** may be in the target language in the source file,
but must also be covered by XLIFF translations for all supported locales.

## Anti Pattern

```al
// WRONG: Danish identifiers
var
    Kreditor: Record Vendor;
    Beløb: Decimal;
    AntalKilo: Decimal;

procedure BeregnTotalbeløb(Antal: Decimal; Pris: Decimal): Decimal
begin
    exit(Antal * Pris);
end;

field(50101; "Indgående Mængde"; Decimal) { Caption = 'Indgående Mængde'; }
```

## Best Practice

```al
// CORRECT: English identifiers, Danish captions handled via XLIFF
var
    Vendor: Record Vendor;
    Amount: Decimal;
    QuantityKg: Decimal;

procedure CalculateTotalAmount(Quantity: Decimal; UnitPrice: Decimal): Decimal
begin
    exit(Quantity * UnitPrice);
end;

field(50101; "Inbound Quantity"; Decimal) { Caption = 'Inbound Quantity'; }
// Caption translation → da-DK XLIFF: 'Indgående Mængde'

// WRONG: Danish label identifier and text
var
    BeløbFejlTxt: Label 'Beløbet må ikke være negativt';

// CORRECT: English label identifier and default text — translated via XLIFF
var
    AmountMustNotBeNegativeErr: Label 'Amount must not be negative.', Comment = '%1 = Amount';
```

## Conversation vs. code

The developer may describe requirements in Danish. The agent must translate
the intent into English identifiers when writing AL code:

- "opret en variabel til beløbet" → `var Amount: Decimal;`
- "procedure der beregner lagerværdien" → `procedure CalculateInventoryValue(...)`
- "felt til indgående mængde" → `field(... ; "Inbound Quantity"; Decimal)`

Never echo Danish words from the conversation directly into AL identifiers.
