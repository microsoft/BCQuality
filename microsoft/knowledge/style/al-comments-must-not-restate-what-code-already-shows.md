---
bc-version: [all]
domain: style
keywords: [comments, verbosity, self-documenting, restate, tutorial-style]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Comments must not restate what the code already shows

## Description

A comment above nearly every statement that just narrates what the statement already says (`// Validate the customer number` above `SalesHeader.Validate("Sell-to Customer No.", CustomerNo)`) adds noise without adding information. Production AL — the Base Application, mature partner codebases — is comment-sparse by comparison: identifiers do the explaining, and a comment appears only when the code alone can't carry the reason.

A comment earns its place only when it captures something the code cannot: a non-obvious business rule, a workaround for a specific platform limitation, or a constraint that would surprise the next reader. If removing the comment would leave the reader no worse off, the comment should not have been written.

This does not override required structural documentation — feature/scenario test tags and XML-doc summaries on public library procedures remain required where they apply; those are structural markers, not narrative comments.

## Best Practice

Let the code speak for itself; reserve comments for the reason a reader could not otherwise infer.

See sample: `al-comments-must-not-restate-what-code-already-shows.good.al`.

## Anti Pattern

A comment line before every statement, repeating in English what the statement's own identifiers already say.

See sample: `al-comments-must-not-restate-what-code-already-shows.bad.al`.
