---
bc-version: [all]
domain: style
keywords: [setfilter, fieldref-setfilter, date-filter, 0d, blank-date, replacement-value, regional-settings, date-format, filter-expression, today]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Pass date operands to SetFilter as replacement values, not as text in the filter string

## Description

The `String` argument of `SetFilter` is parsed at run time as a filter expression. On a `Date` field it behaves like a date filter typed by the user: date text follows the session's region, and date formulas are expanded. An AL date constant written inside that string is therefore not a constant. In an empirical probe on a BC 28.5 online sandbox with the user region set to Danish and to English (United States), `SetFilter("Ending Date", '0D|>=%1', ReferenceDate)` with `ReferenceDate` = 2026-10-29 = today produced the filter `29-10-26|>=29-10-26` (`10/29/26|>=10/29/26`): `0D` became today's date, not the blank date, and not the work date. `'0D..%1'` likewise started the range at today. Neither call raised an error; the record set was silently wrong in both regions. The reading of `0D` matches the documented date formula `10D` meaning "10 days from today".

Date text inside the string depends on the region instead. `'29-10-2026..'` filtered correctly in the Danish region and raised "The format of the Date '29-10-2026' does not match your device's date settings" in the English (United States) region. Code that works on the developer's machine can fail, or filter a different set, for another user.

`'<>0D'` is a trap for tests: on data with one blank date and one date equal to today it returns the same count whether `0D` means blank or today, so a passing test does not prove the filter is right.

## Best Practice

Keep only operators in the filter string and pass every `Date` operand through a replacement field (`%1`, `%2`) with a value of the field's type: `SetFilter("Ending Date", '%1|>=%2', 0D, ReferenceDate)`. In the probe, a replacement value was applied as a typed value, so `0D` stayed the blank date and no region parsing happened; Learn itself requires only that the value's type match the field. Write fixed dates as AL date constants (`20261029D`), which are region independent, and pass them the same way. Where no operator is needed, `SetRange(Field, 0D)` and `SetRange(Field, 0D, ToDate)` express blank and from-the-beginning without any filter text.

Not findings: a filter the user entered (request page, `FilterPageBuilder`, filter field), a `GetFilter`/`GetFilters`/`GetView` round trip (not date text written by the code, and outside this article), and filters on `DateFormula` fields, where `'<>0D'` is a zero-day formula, not a date. Unbracketed formula letters are language dependent; see [`dateformula-evaluate-needs-language-independent-literals.md`](dateformula-evaluate-needs-language-independent-literals.md).

See sample: [`setfilter-date-operands-must-be-replacement-values.good.al`](setfilter-date-operands-must-be-replacement-values.good.al).

## Anti Pattern

`Record.SetFilter` or `FieldRef.SetFilter` on a `Date` field whose constant `String` contains `0D` (`'0D|>=%1'`, `'0D..%1'`, `'<>0D'`) or a date written as text (`'29-10-2026..'`, `'>=10/29/2026'`, `'010116'`). Detection signal: a `SetFilter` call on a field declared `Date` where the string literal contains `0D` or digits outside a `%n` replacement field. Severity rises when the filtered set is posted, modified, deleted, or used to choose a price or a validity period.

See sample: [`setfilter-date-operands-must-be-replacement-values.bad.al`](setfilter-date-operands-must-be-replacement-values.bad.al).

## References

- [Record.SetFilter method](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-setfilter-method): "You can use replacement fields (%1, %2, and so on) to insert values at run-time" and "The data type of Value must match the data type of Field."
- [Work with calendar dates and times](https://learn.microsoft.com/en-us/dynamics365/business-central/ui-enter-date-ranges): "The Region setting determines how dates, times, numbers, and currencies are shown or formatted"; "You can enter date formulas in various date calculation fields or filters"; `10D` = "10 days from today"; `t`/`today` and `w`/`work date` are words in the session language.
- [Date data type](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/date/date-data-type): "An undefined or blank date is specified by 0D" and the `yyyymmddD` constant syntax.
- Empirical probe, BC 28.5 SaaS sandbox, temporary `Price List Line`, user region Danish and English (United States): `'%1|>=%2', 0D, ReferenceDate` and `'''''|>=%1', ReferenceDate` correct in both; `'0D|>=%1'` and `'0D..%1'` wrong in both (GetFilter as quoted above); `SetFilter("Ending Date", '0D')` with the work date moved to 2025-01-15 gave today's date; `'29-10-2026..'` correct in Danish, rejected in English (United States); `'10/29/2026..'` correct in both, a result the probe does not explain, so it is not evidence that US-format text is safe.
- BCApps contains the anti-pattern in a test helper, [`VendorLedgerEntry.SetFilter("Due Date", '0D..%1', DueDate)`](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Layers/DE/Tests/Local/ERMSalesPurchaseReport.Codeunit.al#L756), and the compliant form in application code, [`Rec.SetFilter("Ending Date", '%1|>=%2', 0D, TransactionDate)`](https://github.com/microsoft/BCApps/blob/837ef802485ee457e52310d2ecaa08b93d0122fd/src/Apps/W1/ExpenseAgent/app/src/MasterData/Tables/MileageRateSetup.Table.al#L164).
