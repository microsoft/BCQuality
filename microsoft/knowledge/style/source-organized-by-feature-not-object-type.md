---
bc-version: [all]
domain: style
keywords: [folder-structure, feature-organization, source-layout, maintainability]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Organize AL source by business feature, not object type

## Description

Source folders inside an AL app should group files by the business feature or module they belong to (`src/Sales/Invoice/`, `src/NoSeries/`), not by which kind of AL object they are (`src/Tables/`, `src/Pages/`, `src/Codeunits/`). Object-type folders scatter everything belonging to one feature across half a dozen directories, so a developer picking up a feature has to jump between folders that share nothing but object type to see the whole picture. Feature folders keep a table, its pages, its codeunits, and its test setup physically together.

Code genuinely shared across multiple features (utility codeunits, common interfaces, shared enums) belongs in a `Common` or `Shared` folder, not duplicated per feature and not left in a catch-all root.

## Best Practice

    src/
    ├── NoSeries/
    ├── Sales/
    │   ├── Invoice/
    │   └── Order/
    └── Common/

Each feature folder holds every object type it needs; shared code has one dedicated home.

## Anti Pattern

    src/
    ├── Tables/
    ├── Pages/
    └── Codeunits/

Finding everything related to one feature now requires searching multiple folders and mentally reassembling it from scattered pieces.
