---
bc-version: [all]
domain: security
keywords: [filtergroup, filter-group, setrange, setfilter, subpagelink, filter-overwrite, record-scope, page-filters]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Restore the filter group after setting hidden filters, and do not reuse platform groups

## Description

`FilterGroup(N)` changes the current group for every later `SetRange`/`SetFilter` on that record variable until it is changed again. Each field holds one filter per group, so a later filter on the same field in the same group replaces the earlier one instead of combining with it. Code that switches to a hidden group and does not switch back leaves the record in that group: subsequent code, or a procedure that receives the record, then overwrites the hidden restriction instead of adding to it, and the page's scope widens without any visible change.

Several groups are used by the platform: 1 global, 2 `SourceTableView`/`SetTableView`/`DataItemTableView`, 3 `RunPageView`/`SubPageView`, 4 `SubPageLink`/`DataItemLink`, 6 security filters, and 7 FactBox state. Writing a custom filter into 4 replaces the link between a subpage and its header; using 7 can break FactBoxes. Microsoft documents that these groups should not be used. Group 2 is the established exception for page code, where it extends the page's own table view.

## Best Practice

Save the current group, switch, set the hidden filters, and restore the saved group in the same procedure. Use group 2 for page-level scope restrictions (matching Base Application practice) or a group number above 7 for module-private hidden filters on a record variable you own. Do not set filters in groups 1, 3, 4, 6, or 7.

See sample: [`restore-the-filtergroup-after-setting-hidden-filters.good.al`](restore-the-filtergroup-after-setting-hidden-filters.good.al).

## Anti Pattern

A `FilterGroup(N)` call with N not 0 that is not followed by a restore before the procedure ends, or before the record is passed on or filtered further. Also a custom `SetRange`/`SetFilter` in filter group 4, 6, or 7, or in 1 or 3, on a page, report, or link-driven record.

Do not flag a procedure that sets a hidden group on a local record variable it discards immediately afterwards, or a `FilterGroup()` call that only reads the current group.

See sample: [`restore-the-filtergroup-after-setting-hidden-filters.bad.al`](restore-the-filtergroup-after-setting-hidden-filters.bad.al).

## References

[Record.FilterGroup method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-filtergroup-method#remarks): table of platform filter groups, the warning that using group 4 replaces `SubPageLink` filtering, the warning about group 7, and the rule that filters in all groups are combined.
