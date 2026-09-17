---
bc-version: [all]
domain: style
keywords: [label, scope, procedure, translation, localization, xliff, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Procedure-local Labels are valid

## Description

The AL language supports `Label` variables at both object and procedure scope. Microsoft documents the [Label data type](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-using-labels#label-data-type) without imposing an object-scope requirement, and the translation pipeline generates an XLF file containing [all labels used by the extension](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-work-with-translation-files#generating-the-xliff-file). There is no documented correctness or localization defect caused solely by declaring a Label in a procedure-local `var` block.

## Best Practice

Choose object scope when a Label is reused or when an established repository convention prefers central declarations; choose procedure scope when the Label belongs to one procedure. Do not report a correctness or localization finding solely because a Label is local. An explicit object-scope convention is at most a low-severity maintainability preference. This guidance applies equally to production and test apps: test code still needs localization where its strings are user-facing or translator-facing.
