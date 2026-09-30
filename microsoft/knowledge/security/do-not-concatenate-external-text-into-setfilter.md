---
bc-version: [all]
domain: security
keywords: [setfilter, setrange, filter-expression, filter-injection, external-input, wildcard, deleteall, modifyall]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not concatenate external text into a SetFilter expression

## Description

The `String` argument of `SetFilter` is a filter expression, not a value. Characters such as `..`, `|`, `&`, `<`, `>`, `=`, `*`, `?`, `@`, parentheses, and single quotes are operators. Text from a user, request page, API payload, file, or another system that is concatenated into that expression can therefore change which records match: `*` matches every value, `A|B` widens an exact lookup to two values, `10000..` becomes a range, and `J & V` becomes a conjunction or an invalid filter. `SetFilter` with an empty expression applies no filter at all. When the filtered record is then modified, deleted, exported, or used for a permission-relevant decision, the procedure acts on records the caller never identified.

## Best Practice

Treat an externally supplied identifier as a value. Use `SetRange(Field, Value)` for equality and `SetRange(Field, FromValue, ToValue)` for a typed range; neither parses operators. Reject an empty identifier explicitly when "no value" must not mean "every record". For several external values, apply `SetRange` once per value instead of joining them with `|`.

Use `SetFilter` when an operator is part of the procedure's own contract. Keep the operator in a constant expression and pass operands through replacement fields (`%1`, `%2`) of the field's data type, such as a `Date` or `Decimal` operand for `'>=%1'`. Do not rely on wrapping text in single quotes to neutralize it: according to the filter syntax, quotes protect `&`, `(`, `)`, `=`, and `|`, but `*` still acts as a wildcard inside `'J & V*'`.

Text that the user deliberately entered as a filter is supposed to be parsed. Do not report a request-page or `FilterPageBuilder` filter, a `GetFilters`/`GetView` round trip, a FlowFilter, or a field whose documented purpose is to hold a filter expression. Constant filter strings and operands produced by the extension's own code are also not external input.

See sample: [`do-not-concatenate-external-text-into-setfilter.good.al`](do-not-concatenate-external-text-into-setfilter.good.al).

## Anti Pattern

`Rec.SetFilter(Field, ExternalText)` or `Rec.SetFilter(Field, Prefix + ExternalText + Suffix)` where the text is meant to identify one record or a known list of records, with no validation that restricts it to a literal value. The finding is strongest when the resulting set is written by `Modify`, `ModifyAll`, `Delete`, or `DeleteAll`, or is returned to an external caller. Detection signal: a non-constant expression, concatenation, or `StrSubstNo` result passed as the `String` argument of `SetFilter`, where the operand comes from a parameter, page field, JSON/XML value, file line, or HTTP request.

See sample: [`do-not-concatenate-external-text-into-setfilter.bad.al`](do-not-concatenate-external-text-into-setfilter.bad.al).

## References

- [Record.SetFilter method, including the empty-filter remark](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/methods-auto/record/record-setfilter-method)
- [Filtering with SetRange and SetFilter](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-setcurrentkey-setrange-setfilter-getrangemin-and-getrangemax-methods)
- [Filter criteria, operators, and values that contain symbols](https://learn.microsoft.com/en-us/dynamics365/business-central/ui-enter-criteria-filters#filter-criteria-and-operators)
