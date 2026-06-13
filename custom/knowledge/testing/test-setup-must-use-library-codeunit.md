---
bc-version: [all]
domain: testing
keywords: [test, library, setup, initialize, suppresscommit, asserterror]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

In CURABIS test apps, all test setup is centralized in a dedicated Test Library
codeunit (e.g. `SV Test Library`). Individual test procedures must not call
BC standard library codeunits (`LibrarySales`, `LibraryInventory`, etc.) directly.

Additionally, two rules apply to every test that calls a posting codeunit:

1. `SetSuppressCommit(true)` must be called before `Run()` to prevent data
   from leaking between tests.
2. `asserterror` must always be followed by `Assert.ExpectedErrorCode()` or
   `Assert.ExpectedError()` — a naked `asserterror` passes on any error,
   not just the expected one.

## Anti Pattern

```al
// WRONG: inline setup bypassing the test library
procedure MyTest()
var
    Item: Record Item;
begin
    LibraryInventory.CreateItem(Item);   // do not call directly
    // ...
end;
```

```al
// WRONG: posting without SuppressCommit
SVPost.Run(SVHeader);   // commits to test database
```

```al
// WRONG: naked asserterror
asserterror SVPost.Run(SVHeader);
// no assertion follows — passes on any error
```

## Best Practice

```al
// CORRECT: delegate to test library
procedure MyTest()
var
    Item: Record Item;
begin
    SVLib.GivenScrapItem(Item);   // test library owns setup
    // ...
end;
```

```al
// CORRECT: SuppressCommit before Run
SVPost.SetSuppressCommit(true);
SVPost.Run(SVHeader);
```

```al
// CORRECT: asserterror followed by assertion
asserterror SVPost.Run(SVHeader);
Assert.ExpectedErrorCode('Dialog');
```
