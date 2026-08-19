---
bc-version: [all]
domain: architecture
keywords: [xrec, trigger, onmodify, ondelete, transaction, test-codeunit, change-detection]
technologies: [al]
countries: [w1]
application-area: [all]
---

# xRec is unreliable for change detection within the same uncommitted transaction as a prior Insert or Modify

## Description

The standard AL idiom for detecting whether a field changed inside `OnModify`
(or `OnDelete`) is `if "Field" <> xRec."Field" then ...` — this is used
throughout the base application and is normally trustworthy. But `xRec` was
observed, empirically and reproducibly, to **mirror `Rec`'s new value instead
of the record's stored value** when the `Modify` call runs against a record
that was `Insert`ed (or previously `Modify`ed) earlier in the same
**uncommitted transaction** — no explicit `Commit` in between.

Confirmed via three successive diagnostic `Error()` calls inside the trigger
itself: with the record obtained by `Get()` immediately before the field
change (not even the same in-memory variable that did the `Insert`), `xRec`
still showed the new value, identical to `Rec`. A **fresh `Record.Get()` call
issued from inside the same trigger**, on the same primary key, correctly
returned the true stored (old) value.

This is exactly the shape of the most common AL test codeunit: `Insert` a
record, then `Modify` it later in the same `[Test]` method to exercise an
`OnModify` rule — no `Commit` between them, because test methods run inside
an implicit rollback transaction. Any table trigger authored and validated
only against that pattern will appear correct while silently never firing.

## Rule

A table trigger that needs a field's previously-stored value to decide
whether something changed must not trust `xRec` alone if the record may have
been `Insert`ed or `Modify`ed earlier in the same uncommitted transaction —
re-fetch the comparison value explicitly with a fresh `Get()` call inside the
trigger instead:

```al
trigger OnModify()
var
    Existing: Record "Some Table";
begin
    Existing.Get(PrimaryKeyFields);
    if "Field" <> Existing."Field" then
        Error(FieldLockedErr);
end;
```

This costs one extra `Get()` per `Modify` call — negligible — and is correct
regardless of whether a `Commit` happened since the record was last written.

## What NOT to do

- Do not assume `xRec` is trustworthy just because the trigger "looks like"
  every other `xRec`-comparison trigger in the base app — those are typically
  exercised through a client session where each user action commits, not
  through code that inserts and modifies in one uncommitted batch
- Do not "fix" a failing test by adding a `Commit()` between the `Insert` and
  the `Modify` — that breaks the test's atomicity/rollback isolation and
  papers over a real production risk: any code path that inserts and later
  modifies a record without an intervening commit (batch jobs, import
  routines, cascades) hits the same silent misdetection

## Signal to watch for

An `OnModify`/`OnDelete` trigger comparing `Rec`/`"Field"` against
`xRec."Field"` to gate a rule (block a change, trigger a cascade, decide
whether to log), where a test exercises it by inserting the record and then
modifying it within the same `[Test]` method — and the test passes even
though manual inspection shows the guarded condition should have fired. In
review: any `<> xRec.` comparison inside a trigger, paired with a same-method
Insert-then-Modify in its test.

## Message to developer

When an `xRec`-based trigger check appears to silently not fire in a test
that inserts then modifies the same record: don't assume the guard condition
or the test data is wrong — diagnose with a throwaway `Error()` printing both
`xRec."Field"` and a fresh `Get()`'s value side by side. If they differ,
switch the trigger to compare against the fresh `Get()`, not `xRec`.
