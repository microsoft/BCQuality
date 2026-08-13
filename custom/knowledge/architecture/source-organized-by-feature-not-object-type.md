---
bc-version: [all]
domain: architecture
keywords: [folder-structure, feature-organization, source-layout, maintainability]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL source is organized by business feature, not by object type

## Description

Source folders inside an AL app should group files by the business feature
or module they belong to (`src/Sales/Invoice/`, `src/NoSeries/`), not by
which kind of AL object they are (`src/Tables/`, `src/Pages/`,
`src/Codeunits/`). Object-type folders scatter everything belonging to one
feature across half a dozen directories, so a developer picking up a
feature has to jump between folders that share nothing but object type to
see the whole picture. Feature folders keep a table, its pages, its
codeunits, and its test setup physically together.

Code genuinely shared across multiple features (utility codeunits,
common interfaces, shared enums) belongs in a `Common` or `Shared` folder,
not duplicated per feature and not left in a catch-all root.

## Best Practice

```
src/
├── NoSeries/
├── Sales/
│   ├── Invoice/
│   └── Order/
└── Common/
```

## Anti Pattern

```
src/
├── Tables/
├── Pages/
└── Codeunits/
```

Finding everything related to "Sales Invoice" now requires searching three
separate folders and mentally reassembling the feature from its scattered
pieces.

## Source

alguidelines.dev, "AL Code Style & Formatting" (Microsoft-endorsed
community guidance), cross-checked against CURABIS's own knowledge base
(2026-08-13) — no existing rule addressed source folder layout by feature
vs. object type; this fills that gap.
