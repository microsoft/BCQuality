---
bc-version: [all]
domain: ui
keywords: [pages, page-design, naming-conventions, page-type, card-page, list-page, factbox, worksheet-page, document-page, rolecenter, cardpageid, autosplitkey]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pages must match one of Business Central's page-type conventions

## Description

Business Central's page types — RoleCenter, Card, List, CardPart,
ListPart, Worksheet, Document, ListPlus, plus the system dialog types
(Navigate, ConfirmationDialog, StandardDialog, HeadlinePart, API) — each
fix a naming pattern and a structural constraint, not just a visual
layout. A page whose name, primary-key handling, or linkage
(`CardPageID`, `SubPageLink`, `AutoSplitKey`) doesn't match its own type's
conventions is either the wrong page type for the job or built
inconsistently with the rest of the application, and should be flagged in
review even if it compiles and renders. Before naming a new page or
wiring its links, first ask which page type it is, and whether the source
table actually fits that type's structural requirement — the type fixes
the naming suffix, which fields are visible, and which other page it must
link back to.

## Best Practice

Match the page's design to its type:

- **RoleCenter** — tailored home page for a role; named role + `Role
  Center`; links to List pages, shows Cues/Activities.
- **Card** — view/edit one record; named table + `Card`; FastTabs only,
  first FastTab named `General`. Requires a single-field primary key — a
  multi-field key needs a List/Worksheet/Tabular page instead.
- **List** — view multiple records, also the lookup/drilldown surface;
  named table + `List` if read-only, or the plural table name if
  editable; primary-key fields shown left-most; `CardPageID` must point
  at the associated Card page when one exists.
- **CardPart** — single-column FactBox; named for its content +
  `FactBox`.
- **ListPart** — multi-column FactBox or subpage (e.g. document lines);
  named for its content + `FactBox`/`SubPage`; `SubPageLink` must
  actually filter to the host record.
- **Worksheet** — multi-record entry for a Journal-like table, insertion
  order preserved; primary-key fields never shown; uses `AutoSplitKey`
  with a trailing `Integer` key field.
- **Document** — FastTabs plus a lines subpage, lines filtered to the
  header; named for the document (`Sales Invoice`).
- **ListPlus** — like Document but with multiple lists instead of one;
  named like the record/report it summarizes.
- System dialog types (`Navigate`, `ConfirmationDialog`,
  `StandardDialog`, `HeadlinePart`) are fixed shapes with no page-name
  suffix convention. `API` pages follow their own property rules and are
  extended by adding a new API page, never a page extension.

Before wiring controls, the design step should fix: which users and
tasks the page serves, the concrete fields/commands/links those tasks
need, the page type that matches the content (chosen before the source
table), and the source table that actually holds the page's primary data.

See sample: `page-design-must-match-bc-page-type-conventions.good.al`.

## Anti Pattern

A page that mixes conventions from two types — for example, a "Card"
page built on a table with a two-field primary key, or a "List" page
with no `CardPageID` even though a Card page exists for the same table —
signals a design step was skipped, not a stylistic choice. Also watch
for: a Worksheet or List page showing primary-key fields it shouldn't (or
hiding them when it should show them), and a page with no
`UsageCategory` set, which makes it invisible to Tell Me search even
though it otherwise works.

See sample: `page-design-must-match-bc-page-type-conventions.bad.al`.
