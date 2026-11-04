---
bc-version: [all]
domain: style
keywords: [object-name, length, prefix, affix, 30-characters, 20-characters, permission-set, assignable, al0305, appsource]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep object names within the 30-character platform limit

## Description

Business Central object names — for tables, pages, codeunits, reports, queries, XML ports, enums, and permission sets — are limited to 30 characters in total. Permission sets have a stricter exception: a permission set with `Assignable = true` is limited to 20 characters; the 30-character limit applies only when `Assignable = false`. Exceeding either limit is compiler error AL0305, so the name fails at build time, not only during publish or AppSource validation. AppSource and per-tenant extensions also have to carry a mandatory prefix or affix (typically 3–4 characters), which leaves roughly 26 characters for the descriptive part of most object names, and roughly 16 for an assignable permission set. Over-aggressive abbreviation to fit (`CustLE`, `SIPoster`, `SalesInv`) makes the object name opaque to reviewers and to anyone reading dependency lists. The right move is to plan name length around the budget — descriptive base + prefix — not to discover the limit from the compiler or during AppSource validation.

## Best Practice

Choose a clear, descriptive name in the 20–26-character range and reserve the remaining characters for the mandatory app prefix. `"Customer Ledger Entry"`, `"Sales Invoice Posting"`, `"Sales Invoice"` are descriptive and well under the budget. For an assignable permission set, the complete name including prefix or affix must fit in 20 characters, so the 20–26-character range does not apply. When you genuinely need to abbreviate, prefer abbreviations that are already established in BC (`Cust.`, `Vend.`, `Gen. Jnl.`, `WHSE`) over ad-hoc shortenings.

## Anti Pattern

Names like `"CustLE"` or `"SIPoster"` that abbreviate beyond comprehensibility, names like `"Customer Ledger Entry Posting Helper Codeunit"` that breach 30 characters and force a rename, or an assignable permission set named within 21–30 characters, which looks compliant with the general limit but fails with AL0305.

## See also

- [Compiler Error AL0305](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/diagnostics/diagnostic-al305)
- [Assignable property](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/properties/devenv-assignable-property)
