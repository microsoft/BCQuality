---
bc-version: [all]
domain: architecture
keywords: [namespace, using, compile, al-language, tablerelation, variable, codeunit]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

When an agent adds a variable referencing a BC or custom object, it must verify
the correct namespace by reading the source file of that object — not by guessing
or relying on its training data.

An AL file that "compiles" in the agent's own build may still show as red in
VS Code because the AL Language Server resolves namespaces differently.
The authoritative source for a namespace is always the object's own source file.

This rule applies to:
- `using` declarations at the top of a codeunit, table, page or enum
- Variable declarations that reference tables, codeunits, pages or enums
- `TableRelation` and `CalcFormula` references

## How to verify a namespace

Before adding a `using` statement or a variable referencing an object, the agent
must locate and read the source file for that object:

```
// Step 1: Find the source file
Glob: "**/[ObjectName].*.al"  or  al_symbolsearch query: "[ObjectName]"

// Step 2: Read the first line — the namespace declaration
namespace SettlementVoucher.SettlementVoucher;   ← this is what to use

// Step 3: Add the using statement in the consuming file
using SettlementVoucher.SettlementVoucher;
```

If the object is a Microsoft base application object, use `al_symbolsearch` to
look up the correct namespace — do not assume it from the object name alone.
Microsoft namespaces changed significantly from BC24 onwards.

## Anti Pattern

```al
// WRONG: Guessing the namespace from the object name
using Microsoft.Purchases.Vendor;    // guessed — may be wrong
using SettlementVoucher;             // incomplete — missing sub-namespace

var
    Vendor: Record Vendor;           // missing using → red in AL Language Server
    SVPost: Codeunit "SV Post";      // wrong namespace → unresolved reference
```

## Best Practice

```al
// CORRECT: Read SVPost.Codeunit.al first → find: namespace SettlementVoucher.SettlementVoucher
// CORRECT: Use al_symbolsearch to find Vendor → namespace Microsoft.Purchases.Vendor

using Microsoft.Purchases.Vendor;
using Microsoft.Finance.GeneralLedger.Ledger;
using SettlementVoucher.SettlementVoucher;

codeunit 50204 "SV Incoming Item Flow Tests"
{
    var
        Vendor: Record Vendor;
        GLEntry: Record "G/L Entry";
        SVPost: Codeunit "SV Post";
```

## Verification step before delivering code

After writing any AL file, the agent must:

1. List every `using` statement in the file
2. For each one: confirm the namespace was read from the actual source file
   or looked up via `al_symbolsearch` — not assumed
3. If any namespace was assumed rather than verified, re-read the source and correct it

Never report "compiled successfully" based on a build that did not go through
the AL Language Server in VS Code. The definitive compilation result is what
VS Code shows — not the agent's internal build.
