---
bc-version: [all]
domain: architecture
keywords: [pages, page-design, naming-conventions, page-type, card-page, list-page, factbox, worksheet-page, document-page, rolecenter, cardpageid, autosplitkey]
technologies: [al]
countries: [w1]
application-area: [all]
---

# CURABIS Architecture: BC Page-Type Conventions

## Description

Business Central's page types — RoleCenter, Card, List, CardPart, ListPart,
Worksheet, Document, ListPlus, plus the system dialog types (Navigate,
ConfirmationDialog, StandardDialog, HeadlinePart, API) — each fix a naming
pattern and a structural constraint, not just a visual layout. A page whose
name, primary-key handling, or linkage (`CardPageID`, `SubPageLink`,
`AutoSplitKey`) doesn't match its own type's conventions is either the wrong
page type for the job or built inconsistently with the rest of the
application, and should be flagged in review even if it compiles and renders.

## Key Principle

"Before naming a new page or wiring its links, first ask: which page type is
this, and does the source table actually fit that type's structural
requirement (e.g. a Card page needs a single-field primary key)? The type
fixes the naming suffix, which fields are visible, and which other page it
must link back to."

## The Page Types

### RoleCenter
- **Purpose:** the tailored home page for a role; links to List pages, shows Cues/Activities, may embed system parts (Outlook Inbox, Notes).
- **Naming:** role name + `Role Center` (`Order Processor Role Center`).

### Card
- **Purpose:** view/edit one record at a time.
- **Naming:** table name + `Card` (`Customer Card`).
- **Structural constraint:** always has FastTabs, never plain tabs; the first FastTab is always named `General`. A table only gets a Card page if its primary key has exactly one field — that field is always the first field shown in `General`. A table with a multi-field primary key needs a different page type (List/Worksheet/Tabular), not a Card page.

### List
- **Purpose:** view multiple records from a table at once; also serves as the lookup/drilldown surface.
- **Naming:** table name + `List` if the page is not editable (`Customer List`); plural of the table name if it is editable (`Currencies`).
- **Structural constraint:** primary-key fields are shown in the left-most columns. Its `CardPageID` property must point at the associated Card page, if one exists.

### CardPart
- **Purpose:** a single-column FactBox — fields or a special control (e.g. picture viewer) for a record shown on another page.
- **Naming:** the information it shows + `FactBox` (`Sales Hist. Sell-to FactBox`).

### ListPart
- **Purpose:** a multi-column FactBox, or a subpage (e.g. document lines).
- **Naming:** the information it shows + `FactBox` or `SubPage` (`Dimensions FactBox`).
- See [[factbox-design]] for `SubPageLink` filtering and SIFT-backed FlowField guidance — this rule only governs naming/classification, not FactBox internals.

### Worksheet
- **Purpose:** multi-record entry page for a Journal (or similar) table; inserted records keep their entry order instead of re-sorting by key.
- **Naming:** ends in `Journal` for Journal-table worksheets, otherwise named for the table's purpose.
- **Structural constraint:** primary-key fields are never shown; order is preserved via `AutoSplitKey` combined with an `Integer` last-key-field on the source table.

### Document
- **Purpose:** FastTabs plus a lines subpage on one page, lines filtered to the header.
- **Naming:** the name of the document it represents (`Sales Invoice`).

### ListPlus
- **Purpose:** like Document, but with multiple lists at the bottom instead of one (`Sales Invoice Statistics`).
- **Naming:** follows the same pattern as the record/report it summarizes.

### Other system/dialog page types
`Navigate`, `ConfirmationDialog`, `StandardDialog`, and `HeadlinePart` are
fixed system dialog shapes (search-by-transaction, yes/no confirmation,
single-input prompt, rotating RoleCenter headlines respectively) — the
source material defines no page-name-suffix convention for these, so none
is asserted here. `API` pages are governed separately by
[[set-required-api-page-properties]], [[api-page-camelcase-properties]], and
related rules — do not extend an API page via a page extension; add a new
API page instead.

## Review Checklist

1. Which page type is this actually, based on structure and use — not the name someone already gave it?
2. Does the table's primary key shape fit the page type (single field for Card; multi-field with `AutoSplitKey` for Worksheet)?
3. Does the page name carry the expected suffix for its type (`Card`, `List` vs. plural, `FactBox`, `Journal`, `Role Center`)?
4. If this is a List page for a Card-backed table, is `CardPageID` set? If this is a ListPart/CardPart, is `SubPageLink` actually filtering to the host record (see [[factbox-design]])?
5. Is a Worksheet or List page showing primary-key fields it shouldn't (Worksheet), or hiding them when it should show them (List)?

A page that mixes conventions from two types (for example, a "Card" page
built on a table with a two-field primary key, or a "List" page with no
`CardPageID` even though a Card page exists for the same table) signals a
design step was skipped, not a stylistic choice.

## Source

CURABIS Academy course "Your Key to Application Language for Microsoft
Business Central" (rev. July 2022), Chapter 3: Pages, "Page Types and
Characteristics" and "Design Pages: Best Practices" (p. 105–112). The source
material's naming-convention detail is uneven across page types — several
system dialog types (Navigate, ConfirmationDialog, StandardDialog,
HeadlinePart) have no documented naming pattern, which is preserved here
rather than invented. Cross-checked against the current Base Application
page structure as of 2026-08-12 — the taxonomy still holds.
