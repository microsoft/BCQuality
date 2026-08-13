---
bc-version: [all]
domain: style
keywords: [variable-naming, semantic-naming, readability, magic-name, self-documenting]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Variable names must describe what the value means, not just its type

## Description

A variable name must let a reader understand what the value represents
without having to trace every place it is assigned or used. A name built
from a generic type abbreviation plus a sequence number or letter —
`Amt1`, `Amt2`, `Var1`, `OptA`, `Int3`, `TempX` — fails this test: it tells
the reader the data type, which AL already shows via the declaration, but
nothing about the business meaning. `AmountInclVAT` is immediately
readable; `Amt1` requires the reader to go find out what Amt1 is actually
used for.

The fix is not "add more letters" — it is to name the variable for the
business concept it holds: `AmountInclVAT`, `CustomerDiscountPct`,
`RemainingQuantity`, `IsOverdue`. If two variables genuinely hold the same
kind of value in a comparison or calculation (e.g. two amounts being
subtracted), name them for their distinct roles in that calculation
(`OriginalAmount` / `AdjustedAmount`), not for their shared type
(`Amt1` / `Amt2`).

The same failure shows up in a second, more common shape that's easy to
miss because it doesn't look like an abbreviation: a **real record type
name plus a letter suffix** — `ItemA`/`ItemB`/`ItemC`, `VendorA`/`VendorB`.
This is most common in test fixtures, where two records of the same type
play distinct roles the letter suffix erases (e.g. one vendor has a price
configured, the other doesn't and the test expects a zero-price lookup to
fall through to it) — a reader has to go read the test body to learn which
letter means what, exactly the lookup cost this rule exists to avoid. Name
them for the role: `PricedVendor`/`UnpricedVendor`, `ScrapItem`/`RegularItem`,
not for their shared type plus an arbitrary letter.

**Read the sibling declarations before flagging a type+letter name.** A
single-letter suffix on a real type name isn't always the anti-pattern
above — it can be one member of a deliberate, self-consistent naming
family that happens to use single letters for a real reason (a country or
region code, a variant identifier). `ItemN` sitting next to `ItemDk`,
`ItemSE`, `ItemFI` in the same `var` section isn't an unexplained letter —
it's Norway's country code, following the exact same pattern as its
siblings. Flagging `ItemN` in isolation, without reading what else is
declared alongside it, produces a false positive; the letter/suffix only
counts as unexplained if nothing nearby explains it.

**Exception:** short-lived variables in a handful of idiomatic, universally
recognized roles are accepted single-letter, because their entire meaning
is visible in the few lines that declare and use them:
- Loop counters and array indices (`i`, `idx`, `x`).
- The progress step counter in a `Dialog`/progress-window idiom — a status
  iterator whose only job is tracking how far a long-running process has
  gotten (`s`), and the count fed into the update call itself, e.g.
  `Window.Update(1, c)` (`c`).

This exception does not extend to variables that live longer than that
tight idiomatic scope, or that carry business meaning beyond "the current
position" or "the current progress count" — a `Status` field on a table, or
a `Counter` that is read elsewhere in the object, still needs a real name.

## Best Practice

```al
var
    AmountInclVAT: Decimal;
    RemainingQuantity: Decimal;
    IsOverdue: Boolean;
...
for idx := 1 to ArrayLen(SalesLine) do
    TotalAmount += SalesLine[idx];
...
Window.Open('Processing #1#########');
for s := 1 to Item.Count do begin
    c += 1;
    Window.Update(1, Round(c / Item.Count * 10000, 1));
end;
Window.Close();
```

## Anti Pattern

```al
var
    Amt1: Decimal;
    Amt2: Decimal;
    OptA: Option;
    TempX: Integer;
...
if OptA = 1 then
    Amt1 := Amt2 - TempX;
```

A reviewer reading `Amt1 := Amt2 - TempX;` cannot tell what this line is
computing without opening the variable declarations and searching for every
other assignment to `Amt2` and `TempX` first. The same line as
`AmountInclVAT := AmountExclVAT - DiscountAmount;` needs no further lookup.

```al
// Same failure, real-type-name shape — common in test fixtures.
var
    VendorA: Record Vendor;
    VendorB: Record Vendor;
...
LibraryPurchase.CreateVendor(VendorA);
CreateVendorPrice(VendorA, Item, 10);
LibraryPurchase.CreateVendor(VendorB); // no price created for VendorB
Assert.AreEqual(0, PriceMgt.GetVendorPrice(VendorB."No.", Item."No."), '');
```

`VendorA`/`VendorB` tell the reader nothing about why the test needs two
vendors. `PricedVendor`/`UnpricedVendor` would make the assertion make
sense without reading the setup lines above it.
