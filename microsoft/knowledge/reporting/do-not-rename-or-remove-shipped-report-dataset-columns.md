---
bc-version: [all]
domain: reporting
keywords: [report-dataset, column, rename, remove, user-defined-layout, excel-layout, word-layout, data-contract, compatibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not rename or remove columns of a report dataset that has shipped

## Description

A report's dataset column names are the contract that every layout binds to, including layouts that are not in your source code. An Excel layout lists the column names it uses in its *Data* worksheet; these names must exist in the dataset and cannot be renamed. Word layouts bind to the dataset's custom XML part, and RDL layouts reference field names. Customers and partners create user-defined layouts from your report on the **Report Layouts** page, and other extensions can add layouts through report extensions. Renaming a `column(...)` or deleting it compiles cleanly and updates the layouts in your project, but breaks those other layouts: fields render empty, or the layout fails validation or rendering.

Agents treat a column name like a private identifier and "tidy" names (`No_` to `DocumentNo`), or delete columns that their own layout no longer uses.

## Best Practice

Once a report has been released, keep existing column names and keep columns that layouts may use. Add new columns instead of renaming, and keep old ones populated (they can stay unused by your own layouts). If a column must change, ship a new report or a new layout-compatible column alongside the old one, and communicate it as a breaking change for custom layouts.

See sample: [`do-not-rename-or-remove-shipped-report-dataset-columns.good.al`](do-not-rename-or-remove-shipped-report-dataset-columns.good.al).

## Anti Pattern

A diff that renames the name of an existing `column(Name; Source)` in a released report or report extension, or removes such a column, justified by naming style or by "no layout uses it" based only on the layouts in the repository.

Changing a column's source expression while keeping its name and type is not this defect. Neither is changing a report that has never been released (see the unreleased-symbol guidance in breaking-changes).

See sample: [`do-not-rename-or-remove-shipped-report-dataset-columns.bad.al`](do-not-rename-or-remove-shipped-report-dataset-columns.bad.al).

## References

[Creating an Excel layout report, How Excel layouts work](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-howto-excel-report-layout#how-excel-layouts-work) (Data worksheet fields must exist in the dataset and can't be renamed), [Report and document layouts overview](https://learn.microsoft.com/en-us/dynamics365/business-central/ui-manage-report-layouts#layout-sources) (user-defined layouts), and [Update custom report layouts](https://learn.microsoft.com/en-us/dynamics365/business-central/ui-update-report-layouts) (deleted fields can't be handled by the automatic layout update).
