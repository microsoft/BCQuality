---
bc-version: [all]
domain: security
keywords: [filtergroup, filter-group, setrange, setfilter, onopenpage, user-filter, record-scope, security-filter]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Filters that restrict what a page shows must not be set in filter group 0

## Description

Filter group 0 is the standard group: it holds the filters the user sees and edits in the filter pane. A `SetRange` or `SetFilter` issued in page code without a prior `FilterGroup` call lands in group 0, so the user can clear it with one click and see every record in the table. Filters in any other group are invisible to the user and can only be narrowed, never widened. Code that restricts a page to "my" records (the current user's entries, one salesperson's customers, one company's documents) therefore silently stops restricting anything if it is set in group 0.

A non-zero filter group is a UI scope, not a security boundary. A user with read permission on the table can still reach the records through another page, an API, a report, or Excel export. Record-level confidentiality requires security filters on permission sets, or not granting the table at all.

## Best Practice

In `OnOpenPage` (or wherever a page narrows its source records) switch to a non-zero group before setting the restricting filters, then switch back to group 0 so the user's own filters land where the client expects them. Group 2 is the conventional choice in page code: the Base Application uses `FilterGroup(2)` for the same purpose, and it is the group that already holds `SourceTableView` and `SetTableView` filters. Apply the [restore rule](restore-the-filtergroup-after-setting-hidden-filters.md) when doing so.

When the restriction is a confidentiality requirement, enforce it with permission sets and security filters as well, and treat the page filter as a convenience.

See sample: [`page-scope-filters-must-not-be-in-filtergroup-zero.good.al`](page-scope-filters-must-not-be-in-filtergroup-zero.good.al).

## Anti Pattern

A page trigger that limits `Rec` to a user-, role-, or context-specific subset with `SetRange`/`SetFilter` while the current filter group is 0. The user can remove the filter from the filter pane.

The opposite review error is reporting a non-zero filter group as adequate data protection, or flagging group 0 filters that are meant to be a removable default (for example, a default date range the user is supposed to change).

See sample: [`page-scope-filters-must-not-be-in-filtergroup-zero.bad.al`](page-scope-filters-must-not-be-in-filtergroup-zero.bad.al).

## References

[Record.FilterGroup method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-filtergroup-method#remarks): group 0 holds filters set from the filter dialog; a filter in another group cannot be widened by the user. [Using security filters](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/security/security-filters) for record-level security.
