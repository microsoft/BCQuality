---
kind: action-skill
id: al-commit-justification-review
version: 1
title: AL Commit justification review
description: Reviews AL pull request changes for explicit Commit calls without a meaningful adjacent justification and an explanation of data consistency after subsequent failure.
inputs: [pr-diff, file-path, folder-path]
outputs: [findings-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL Commit justification review

This is an independent NAV24 leaf skill that reviews explicit Commit calls in Business Central AL code.

It evaluates the organization-specific Commit justification policy defined in the Custom knowledge layer.

The skill does not invoke other skills and does not replace or modify Microsoft review skills.

It can be selected by an orchestrator that supports BCQuality Entry-based skill discovery and dispatch.

## Source

Load `custom/knowledge/error-handling/commit-must-be-justified-by-comment.md` from the enabled Custom layer using BCQuality READ's discovery and reading rules. Open its entire content before evaluating or citing it. If the article is absent, disabled, or filtered out, return `no-knowledge` with no findings. Use the discovered article's exact path in citations; never invent a reference.

## Relevance

Apply the article's READ frontmatter filters to the target application. Review AL code only. Unknown context must not be treated as proof of a violation; explain uncertainty and lower confidence when it matters.

## Worklist

For `pr-diff`, inspect each explicit `Commit()` or `Commit;` call newly added or changed in AL code. Also inspect an existing call when its directly associated justification comment was added or changed in the diff. Ignore unchanged calls unrelated to the diff. For `file-path` or `folder-path`, inspect all explicit Commit statements in the supplied AL source scope.

Exclude comments and string literals containing the word `Commit`. Exclude AL test codeunits (`Subtype = Test`) and clearly identified test helper code. Track each qualifying Commit statement separately, including multiple calls in one procedure. Read sufficient surrounding code to assess the justification and its consistency claim.

## Action

For every worklist item, inspect the comment block immediately preceding the Commit statement and evaluate the **Best Practice** and **Anti Pattern** in the loaded article. Do not treat a mere mention of `Commit` or `safe` as substantive evidence. Do not infer business guarantees from code that is not available.

Use the severity specified by the article: `major` for a missing or meaningless justification or an observable contradiction; `minor` for a substantive but incomplete explanation. The finding must identify which question is unanswered and cite relevant surrounding code when claiming a contradiction. Do not emit a finding if the article's two requirements are satisfied and the available code does not contradict them.

Set `confidence` to `high` when the comment is absent and to `medium` when judging the quality or credibility of an existing comment, and also cap it at `medium` when any frontmatter dimension was unknown (naming that dimension in `message`). Use the Commit line as `location`. Set `references[0].path` to the exact discovered article path and set `findings[].id` to that same path. Set `findings[].domain` to `Error Handling`. Omit `suggested-code`, because a developer must provide the real justification; include `suggested-code-omission-reason` explaining that it cannot be inferred safely from the diff. Never invent justification text or claim the Commit design is approved.

Return `not-applicable` for input with no AL code, `no-knowledge` when the article cannot be used, and `completed` with empty findings when all qualifying calls were reviewed without violations (including an empty Commit worklist). Use `partial` or `failed` as required by the DO contract if the worklist cannot be completed.

## Output

Return one strict JSON `findings-report` conforming to `skills/do.md`, with accurate `skill`, `outcome`, `summary`, `findings`, and `suppressed` fields. Every knowledge-backed finding must pass DO's reference-integrity rules. Report only actual violations; never emit informational findings merely to show that the article was read. Do not emit agent findings; the scope is only the documented Commit rule.
