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

Folder structure inside an AL app has no effect on compilation or runtime behavior — this is a repository-organization convention, not a platform requirement, and different projects reasonably choose differently. Grouping files by business feature or module (`src/Sales/Invoice/`, `src/NoSeries/`) rather than by AL object type (`src/Tables/`, `src/Pages/`, `src/Codeunits/`) keeps everything belonging to one feature physically together, which many teams find easier to navigate than jumping between object-type folders that share nothing but their AL object kind. Adopt this consistently on a project rather than mixing both schemes, but treat it as a team convention to apply deliberately, not a Microsoft-mandated structure.

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

A repository that documents or has established feature-based organization
as its convention, but then mixes in object-type folders for new work
anyway:

    src/
    ├── Sales/
    │   └── Invoice/
    ├── Tables/          <- new objects land here instead of a feature folder
    └── Codeunits/

The anti-pattern is inconsistency with the project's own chosen convention,
not the object-type scheme itself — a repository that deliberately and
consistently organizes by object type throughout is exercising the other
reasonable choice described above, not violating this rule. What actually
costs a reader time is a codebase where some features live under their own
folder and others are scattered across type folders, so finding everything
related to one feature means checking both schemes and reassembling it from
wherever each object happened to land.
