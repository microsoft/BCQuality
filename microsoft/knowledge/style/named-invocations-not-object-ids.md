---
bc-version: [all]
domain: style
keywords: [page, report, codeunit, runmodal, run, object-id, named-invocation]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Call objects by name, not by numeric ID

## Description

`Page.RunModal`, `Report.Run`, `Codeunit.Run`, and the `Page::`, `Report::`, `Codeunit::`, `Table::`, `XmlPort::` selectors accept either a numeric ID or a named alias. The named form — `Page::"Posted Sales Shipment Lines"`, `Report::"Sales - Invoice"` — is the one to use. Numeric IDs are an implementation detail that change with renumbering, do not survive a rename, and carry no signal to a reader about what the call actually does. The compiler resolves named aliases at build time, so the named form is no slower than the numeric form.

## Best Practice

When invoking an object whose named alias is available in the same app (or in a dependency the current app already references), use the named form: `Page.RunModal(Page::"Posted Sales Shipment Lines", SalesShptLine)`, `Report.Run(Report::"Sales - Invoice", true)`. The same applies to `Codeunit.Run`, `XmlPort.Run`, `Query.Open`, and any platform method that takes an object reference. The named form makes diffs reviewable — a rename is visible — and makes log output and stack traces interpretable.

See sample: [`named-invocations-not-object-ids.good.al`](named-invocations-not-object-ids.good.al).

## Anti Pattern

`Page.RunModal(525, …)` or `Report.Run(206, true)`. The numeric form is unreadable, fragile across renumbering, and breaks every search that looks for callers of a named object.

See sample: [`named-invocations-not-object-ids.bad.al`](named-invocations-not-object-ids.bad.al).
