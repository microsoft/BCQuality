---
bc-version: [all]
domain: style
keywords: [comments, verbosity, self-documenting, restate, training-data-bias, tutorial-style]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL code must not carry comments that just restate what the code already shows

## Description

AL-generating AI assistants have a specific, evidenced tendency to
over-comment: writing a narrative comment above nearly every statement,
even when the statement's own field names, procedure names, and trigger
names already say what it does (`// Validate the customer number` above
`SalesHeader.Validate("Sell-to Customer No.", CustomerNo);`). This is not
a generic LLM habit that happens to also show up in AL — it is worse in AL
specifically, because a disproportionate share of publicly available AL
source (Microsoft Learn samples, partner training courseware, forum
snippets) is written for teaching, where every line is deliberately
narrated for a learner. Production AL — the Base Application, BCApps,
mature partner codebases — is comment-sparse by comparison: identifiers do
the explaining, and a comment appears only when the code alone can't carry
the reason.

A comment earns its place only when it captures something the code cannot:
a non-obvious business rule, a workaround for a specific platform
limitation, or a constraint that would surprise the next reader. If
removing the comment would leave the reader no worse off, the comment
should not have been written.

This does not override the required structural comment tags —
[[test-feature-scenario-tags]]'s `// [FEATURE]`/`// [SCENARIO]`/
`// [GIVEN]`/`// [WHEN]`/`// [THEN]` markers and `///` XML-doc summaries
on public library procedures ([[xmldoc-for-public-library-procedures]])
are structural documentation, not narrative comments, and both remain
required where they apply.

## Anti Pattern

```al
// Set the customer number
SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
// Insert the line
SalesLine.Insert(true);
// Check if the amount is positive
if Amount > 0 then
    // Post the entry
    PostEntry(Amount);
```

Every comment here just repeats the statement below it in English. Deleting
all four comments loses nothing a reader needs.

## Best Practice

```al
SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
SalesLine.Insert(true);
if Amount > 0 then
    PostEntry(Amount);

// Negative amounts arrive from credit memos routed through this codeunit;
// PostEntry() rejects them, so they're filtered before the call.
if Amount < 0 then
    exit;
```

The last comment survives the test: it explains a business reason
(credit-memo routing) the code alone doesn't reveal.

## Source

Consultant feedback relayed by Michael Dieringer (2026-08-13): AI-written
AL code carries frequent unnecessary comments. Sharpened from a general
"don't over-comment" observation to an AL-specific one: the skew in
publicly available AL training material toward tutorial/courseware content
— which is deliberately comment-heavy for teaching — plausibly biases
AL-generating models toward that style even in production contexts, more
so than for languages whose public corpus is dominated by production code.
