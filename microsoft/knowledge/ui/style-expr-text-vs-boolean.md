---
bc-version: [all]
domain: ui
keywords: [style-expr, style, boolean, text-variable, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# StyleExpr: Boolean toggle vs Text variable

## Description

`StyleExpr` on a page field serves two distinct purposes depending on its type:

- **Boolean** — When `StyleExpr` is a Boolean expression, it controls whether the `Style` property is applied. In this case the `Style` property carries the style name; analyze `Style` and ignore `StyleExpr` itself.
- **Text** — When `StyleExpr` is a Text variable (e.g. `StyleExpr = StatusStyle` where `StatusStyle: Text` and is assigned literals such as `'Favorable'`), the variable contains the style name at runtime. There may be no `Style` property at all — the `StyleExpr` variable **is** the style.

When `StyleExpr` is Text, you must trace the variable's assignments — typically in `OnAfterGetRecord` or `OnAfterGetCurrRecord` — to determine which styles can be applied, then apply the same accessibility rules as for a literal `Style` value.

## Best Practice

Inspect the declared type of the symbol referenced by `StyleExpr` before drawing conclusions. If it is Boolean, evaluate the `Style` property. If it is Text, follow every assignment to the variable and check the full set of possible style values against `cosmetic-styles-need-no-textual-context.md` and `semantic-styles-need-independent-textual-meaning.md`.

See sample: [`style-expr-text-vs-boolean.good.al`](style-expr-text-vs-boolean.good.al).
