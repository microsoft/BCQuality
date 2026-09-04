---
bc-version: [all]
domain: testing
keywords: [generateguid, library-utility, test-fixtures, uniqueness, copystr, maxstrlen]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Generate unique test fixture values with LibraryUtility.GenerateGUID()

## Description

A fixture helper that assigns a hardcoded literal to a primary-key or descriptive field collides the moment two tests, or two runs of the same test, create that fixture without cleanup, and a literal longer than the field allows raises a truncation or insert error. `LibraryUtility.GenerateGUID()` returns a value that is unique per call and long enough to guarantee no collision; paired with `CopyStr(..., 1, MaxStrLen(Field))` it fits any fixed-length `Code` or `Text` field safely.

## Best Practice

For a fixture field that must be unique across test runs, assign `CopyStr(LibraryUtility.GenerateGUID(), 1, MaxStrLen(TargetField))` rather than a literal string.

See sample: `use-generateguid-for-unique-test-fixture-values.good.al`.

## Anti Pattern

Hardcoding a fixture value such as `'TEST001'` or a short descriptive literal. It collides across parallel or repeated test runs, and a value longer than the field's length limit is either silently truncated or raises an insert error.

See sample: `use-generateguid-for-unique-test-fixture-values.bad.al`.
