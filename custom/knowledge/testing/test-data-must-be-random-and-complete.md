---
bc-version: [all]
domain: testing
keywords: [test, hardcode, random, library, no-series, setup, data]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

CURABIS tests assume an empty database. All test data must be created
programmatically — never assume existing records or hardcode codes, numbers,
or names that may or may not exist in a given environment.

Three concrete rules:

**1. Use MS Library codeunits for standard BC objects.**
No-series, G/L accounts, customers, vendors, items, locations, posting groups —
all created via `Library - ERM`, `Library - Inventory`, `Library - Sales` etc.
These tools generate random codes that do not collide across test runs.

**2. Fill all required fields with random values.**
A `Code[10]` field gets 10 random characters. A `Text[50]` field gets random text.
Use `Library - Utility` or `Any` codeunit for random generation.
Partial setup that leaves required fields empty is not acceptable.

**3. Build your own tools for custom tables.**
For CURABIS-specific tables (e.g. `Settlement Payment Method`,
`Settlement Voucher Setup`), maintain dedicated setup procedures in the
Test Library codeunit. These procedures must follow the same pattern as
Microsoft's libraries: create records programmatically, use random values
for codes where no fixed value is required by the flow being tested.

**Exception — integration and flow tests.**
When a test validates a specific integration contract (e.g. a fixed JSON
structure from a web service, a specific EDIFACT message, a fixed counterparty
code expected by an external system), hardcoded values are acceptable and
necessary. The test is documenting the contract, not exercising random data.

## Anti Pattern

```al
// WRONG: hardcoded code that may or may not exist
if not PaymentMethod.Get('CASH') then begin
    PaymentMethod.Code := 'CASH';
    ...
end;
```

```al
// WRONG: hardcoded source code
SourceCode.Code := 'SV-POST';
```

```al
// WRONG: partial setup — Code[10] left short
PaymentMethod.Code := 'C';   // not filled to capacity
```

## Best Practice

```al
// CORRECT: random code via LibraryUtility
PaymentMethod.Code :=
    CopyStr(LibraryUtility.GenerateRandomCode(
        PaymentMethod.FieldNo(Code), DATABASE::"Settlement Payment Method"), 1, 10);
PaymentMethod.Description := LibraryUtility.GenerateRandomText(50);
PaymentMethod.Insert();
```

```al
// CORRECT: source code created via standard MS pattern
LibraryERM.CreateSourceCode(SourceCode);
GlobalSourceCode := SourceCode.Code;
// then assign to Source Code Setup
```

```al
// CORRECT: no-series via MS library
GlobalNoSeriesCode := LibraryUtility.GetGlobalNoSeriesCode();
```

```al
// CORRECT: hardcoded in integration test — documenting a contract
// [SCENARIO] Inbound ORDRSP with fixed order reference from Allnet Germany
ExpectedOrderRef := 'ORD-2026-00001';   // fixed by integration contract
```
