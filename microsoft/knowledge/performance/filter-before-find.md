---
bc-version: [all]
domain: performance
keywords: [filter, setrange, setfilter, findset, scan]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Filter before you find

## Description

Every call to FindSet, Find, or FindFirst on an unfiltered record variable scans the entire table. On hot tables (ledger entries, value entries, sales invoice lines) a production dataset can easily be millions of rows, so the cost of forgetting a filter is orders of magnitude worse than the cost of applying one.

## Best Practice

Apply SetRange or SetFilter to narrow the record set before calling FindSet or Find. The filters should match a key on the table (see set-current-key-to-match-filters). When iterating rows that belong to a parent record, set all key-field filters before the find call — never inside the repeat loop.

See sample: `filter-before-find.good.al`.

## Anti Pattern

Calling FindSet with no filters and then discarding rows inside the loop with an if-statement forces the platform to read every row of the table before your code even runs.

See sample: `filter-before-find.bad.al`.

