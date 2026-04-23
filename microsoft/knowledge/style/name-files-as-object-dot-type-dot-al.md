---
bc-version: [all]
domain: style
keywords: [file-name, convention, object-type, al-project]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Name AL files as `<ObjectName>.<ObjectType>.al`

## Description

Business Central AL projects follow a consistent file-naming convention: the file name is the object's name, followed by a dot, followed by the object type (`Page`, `Codeunit`, `Table`, `Report`, `Enum`, etc.), followed by `.al`. `CustomerCard.Page.al`, `PostSalesInvoice.Codeunit.al`, `SalesLine.Table.al`. The convention produces an alphabetically-ordered folder that groups all of an entity's objects (`SalesLine.Table.al`, `SalesLine.TableExt.al`, `SalesLineCard.Page.al`) next to each other, and makes navigation by file name in large repos predictable.

## Best Practice

Match the file name to the object declaration: PascalCase name, type segment, `.al`. Use `TableExt`, `PageExt`, `EnumExt` for the corresponding extension types. When multiple objects share a file (generally discouraged), name the file after the primary object.

## Anti Pattern

`customer_page.al`, `PostSalesInvoiceLogic.al`, `tests_noSeries.al` — all three violate the convention. The first uses snake_case, the second adds a descriptive suffix after the object name, the third prefixes the type instead of suffixing it. Tooling that expects the convention (AL-Go scaffolding, navigation helpers, diff conventions) then misbehaves on these files.
