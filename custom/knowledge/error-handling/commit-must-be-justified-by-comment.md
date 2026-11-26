---
bc-version: [all]
domain: error-handling
keywords: [commit, rollback, transaction, justification, comment, data-consistency, runmodal, codeunit-run, review-policy]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Justify explicit Commit calls and document transaction safety

## Description

In Business Central AL, an explicit `Commit()` or `Commit;` makes preceding database changes permanent. An error after that point does not roll back those changes. NAV24 requires a comment next to every newly introduced or changed explicit Commit call, explaining both why the transaction must end there and why the remaining committed data is acceptable if later processing fails. A comment must document a real, verifiable design decision rather than merely claim that the operation is safe.

This organization-specific policy complements, but does not replace, the standard BCQuality guidance on transaction boundaries, commits in loops, and `Codeunit.Run`.

## Best Practice

Put a comment block immediately above the relevant `Commit()` or `Commit;` statement. Do not put executable code between the comment and the Commit call. A comment in any team language is acceptable if it clearly answers both questions:

1. **Why is Commit needed here?** Name the specific technical or business requirement, and explain what would fail or change if the Commit were removed or moved.
2. **What happens if later processing fails?** Explain what remains permanently stored, why that state is independently valid, or which explicit recovery/compensation process handles an intentionally accepted partial state.

The reviewer must assess whether the explanation is credible in the surrounding AL code. Merely adding a comment does not make an unsafe Commit safe or exempt it from other BCQuality rules.

See sample: [`commit-must-be-justified-by-comment.good.al`](commit-must-be-justified-by-comment.good.al).

## Anti Pattern

Review newly added or modified explicit Commit calls, including changes that introduce or modify their directly associated justification comments. Report:

- **Major:** No directly preceding comment exists, or the comment contains no meaningful justification (for example `// Commit`, `// Needed`, `// TODO`, or `// Safe`).
- **Minor:** The comment explains why the Commit is needed but omits the post-Commit failure/rollback consequence, or describes consistency without explaining why the Commit is needed.
- **Major:** The comment claims that earlier writes remain consistent, but the visible AL code contradicts that claim. Cite the concrete contradiction; do not invent missing application context.

Do not report:

- An unchanged Commit call outside the reviewed changes when the input is a PR diff.
- Commit calls in AL test codeunits (`Subtype = Test`) or clearly identified test helper code.
- Differences in comment language, length, or wording when both required explanations are substantive.

This policy checks the presence and credibility of the justification. It does not independently approve the architecture of the transaction boundary.

See sample: [`commit-must-be-justified-by-comment.bad.al`](commit-must-be-justified-by-comment.bad.al).
