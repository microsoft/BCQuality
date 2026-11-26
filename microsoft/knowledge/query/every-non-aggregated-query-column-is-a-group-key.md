---
bc-version: [all]
domain: query
keywords: [query-totals, method, sum, count, average, group-by, grouping, aggregate, query-column]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Every non-aggregated query column is a group key

## Description

As soon as one query column sets `Method` to `Sum`, `Count`, `Average`, `Min`, or `Max`, the query groups its result by all other columns, including columns of other data items and columns that use a date method (`Day`, `Month`, `Year`). There is no explicit GROUP BY; the grouping is implied by the column list. Adding a column "just to display it", such as a document number, a description, or a posting date, therefore silently changes the grain of the result: one total per customer becomes one total per customer per document, and the code that reads one row per customer reads the first partial total or adds duplicates.

Integer `Average` also uses integer division, so averages of `Integer` fields lose their fractional part.

## Best Practice

Treat the non-aggregated column list as the GROUP BY clause. Include only the columns that define the grain you want, and get descriptive values (names, descriptions) either from a column that is constant within the group or from a separate lookup after reading the totals. When a column is needed only for filtering, use `filter` elements or `ColumnFilter`/`DataItemTableFilter` instead of a `column`. Average `Decimal` fields, or compute the average in AL from `Sum` and `Count`.

See sample: [`every-non-aggregated-query-column-is-a-group-key.good.al`](every-non-aggregated-query-column-is-a-group-key.good.al).

## Anti Pattern

A totals query, meaning one with any aggregate `Method`, that also contains a `column` whose value varies within the intended group (document number, line number, entry number, posting date without a date method), while the query's name or consuming code expects one row per group, for example via a single `Read()` or a dictionary keyed by the group field.

See sample: [`every-non-aggregated-query-column-is-a-group-key.bad.al`](every-non-aggregated-query-column-is-a-group-key.bad.al).

## References

[Aggregating data in query objects](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-query-totals-grouping) (an aggregate method groups the dataset by the other columns; integer Average uses integer division) and [Method property](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/properties/devenv-method-property) (date-method columns remain part of the group).
