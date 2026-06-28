---
bc-version: [all]
domain: ui
keywords: [historical-table, list-page, descending-sort, log-entry, ledger-entry, archive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Default descending sort on historical pages

## Description
Historical list pages should default to showing the newest records first. On pages such as log entries, ledger entries, archives, and other history lists, an oldest-first default order does not align with the primary use of the page, which is typically to review recent activity.

## Best Practice
Set descending sort as the default on list pages whose primary purpose is to present historical records. This is the expected default for entry, log, archive, and posted-history pages unless there is a specific requirement to begin with the oldest record.

See sample: `default-descending-sort-on-historical-pages.good.al`.

## Anti Pattern
Using an oldest-first default order on a historical list page where users are primarily interested in recent activity. Typical signs include history, log, or entry pages that regularly need to be re-sorted to descending during normal use.

See sample: `default-descending-sort-on-historical-pages.bad.al`.