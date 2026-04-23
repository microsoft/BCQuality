---
bc-version: [all]
domain: performance
keywords: [ledger-entry, production-scale, hot-table, item-ledger, gl-entry, sales-invoice-line]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Treat ledger-entry and line-type tables as production-scale when reviewing performance

## Description

A handful of Business Central tables grow to millions of rows in production tenants: Item Ledger Entry, Value Entry, G/L Entry, VAT Entry, Customer Ledger Entry, Vendor Ledger Entry, Sales Invoice Line, Purchase Invoice Line, Detailed Cust. Ledg. Entry, Detailed Vendor Ledg. Entry, and equivalent line-type tables. Master-data tables like Customer, Vendor, and Item typically reach the high hundreds of thousands. A performance review that treats these tables with the same latitude as setup tables or small reference lists under-reports real regressions; the same filter-or-key mistake that is invisible on a 50-row table is a full table scan over millions of rows on these.

## Best Practice

When a code change touches any of the above tables, demand concrete performance reasoning before accepting it: an appropriate key selection, a SetLoadFields narrowing, filters that use the key prefix, no N+1 inside the iteration. A finding on one of these tables should almost never be downgraded from High to Low on the grounds that "the operation looks small" — at production scale the operation is never small.

## Anti Pattern

Applying review heuristics uniformly to all tables. A missing SetCurrentKey on a Setup table changes nothing; the same mistake on Item Ledger Entry turns a list page into a multi-second load. The asymmetry is the whole point of the catalog — knowing which tables warrant the stricter read.
