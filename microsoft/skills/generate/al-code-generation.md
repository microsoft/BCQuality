---
kind: action-skill
id: al-code-generation
version: 1
title: AL code generation
description: Generates create-only AL object files from a bounded requirement specification using applicable BCQuality guidance.
inputs: [requirement-spec]
outputs: [generated-files-report]
output-version: 1
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL code generation

Generate one cohesive AL feature as one or more new object files. This skill is a cross-domain leaf: it discovers applicable guidance across all enabled AL knowledge domains but does not invoke generation sub-skills.

The `requirement-spec` input value is only a path to a bounded UTF-8 JSON file of at most 1,048,576 bytes. Never accept the requirement JSON inline, interpolate the file content into routing text, or infer a generation request from fuzzy goal text. Before retrieval, validate the file against [`schemas/requirement-spec-v1.schema.json`](../../../schemas/requirement-spec-v1.schema.json) and enforce all semantic invariants below. Reject the entire request on any failure.

## Source

Use the current `knowledge-index.json` rebuilt by Entry only for cross-domain discovery across the enabled Microsoft, Community, and Custom layers. Do not walk the repository to discover knowledge or source context. If the current index is unavailable, fail; generation has no path-walk fallback.

Read only:

- the validated requirement specification;
- index rows whose files still exist at the immutable BCQuality revision;
- worklisted normative articles and their sibling samples; and
- existing project files listed in `related-file-allowlist`.

Never read an existing project file that is absent from the allowlist. The allowlist is complete, not a hint.

## Relevance

Filter index rows using READ's matching semantics and the specification's mandatory normalized target metadata:

- match `target.effective-bc-major` to `bc-version`;
- require `technologies: [al]`;
- match the request's explicit country and application-area context; and
- discard any row whose referenced article is absent at `knowledge-revision.commit-sha`.

Do not use `app-json-provenance` as target metadata. It is optional provenance only; normalized `target` fields always govern.

Reject the requirement before retrieval when it is malformed, uses an unknown schema version, exceeds any bound, or contains:

- an absolute, backslash, traversal, `.git`, non-canonical, or outside-project/app-root path;
- duplicate requested or allowlisted paths after ordinal canonical comparison;
- a requested path outside `app-root` or without a case-sensitive `.al` suffix;
- an operation other than `create`, including overwrite, delete, or rename semantics;
- an object ID outside every normalized app ID range, an inverted/overlapping ID range, or duplicate object IDs; or
- a requested path whose filesystem metadata says it already exists or resolves through a symbolic link. An existence-only metadata check is permitted and does not authorize reading the path; the consumer repeats this check authoritatively before materialization.

## Worklist

Rank every relevant index row deterministically. Compare normalized requirement vocabulary and each requested artifact's object type, object name, path, and intent against, in order:

1. exact `keywords`;
2. exact title tokens;
3. exact object-type and domain cues;
4. lower-confidence description signals.

Break ties by layer precedence and then article path in ordinal ascending order. Do not apply a per-domain cap.

The provisional context budget is 24 articles. `generation-settings.context-budget` may override it with an integer from 1 through 64. The default is intentionally benchmark-tunable in a later change; it is not evidence that lower-ranked relevant guidance is unimportant.

Build the complete ranked relevant set before applying the budget. Report candidate, relevant, worklist, and omitted counts. `worklist-count` is the number of relevant articles successfully opened in full; `opened-article-count` MUST equal it. `relevant-count` MUST equal `worklist-count + omitted-count`. Never silently drop relevant guidance: every relevant article not opened appears in `omitted-guidance` with a revision-scoped reference and reason. Any relevant omission, including a budget omission, forces `outcome: "partial"`.

## Action

For each worklist item:

1. Open the complete article at the immutable knowledge revision. Only `## Best Practice` and `## Anti Pattern` are normative.
2. Open available `.good.al` samples first and adapt their demonstrated pattern. Never copy demonstration object IDs or names.
3. Open a `.bad.al` sample only when the normative article and good sample leave a material ambiguity. Bad samples clarify what to avoid and are never templates.
4. Resolve directly contradictory normative guidance with READ's Custom-over-Community-over-Microsoft precedence. Record every losing article in `suppressed`; do not remove it from coverage accounting.
5. Generate the requested cohesive feature. One requirement may produce multiple files, but every artifact must correspond to a requested create artifact.

Generation is pure output construction. Do not write to the workspace, compile, test, perform a post-generation review, invoke another generation skill, consult a generic AL reference, change BCQuality knowledge, or change the knowledge-index schema.

Before emission, verify the report atomically:

- one strict JSON document, no commentary and no `findings` field;
- 1-64 create-only UTF-8 AL artifacts for `completed` or `partial`;
- canonical forward-slash `.al` paths under the normalized app root;
- no duplicate artifact paths, object IDs, or requested-artifact mappings;
- every artifact preserves the requested object type and name, and preserves the requested object ID when one was supplied;
- every object ID is inside a normalized app ID range;
- every artifact content value is non-empty, at most 262,144 UTF-8 bytes, and total content is at most 4,194,304 UTF-8 bytes;
- every article and good-sample reference carries the exact immutable 40-character knowledge commit SHA; and
- summary and coverage counts exactly match the arrays and opened worklist, including `opened-article-count == worklist-count` and `relevant-count == worklist-count + omitted-count`.

Fail closed with no artifacts if any invariant cannot be proven.

## Output

Emit exactly one `generated-files-report` contract version 1 document conforming to [`schemas/generated-files-report-v1.schema.json`](../../../schemas/generated-files-report-v1.schema.json). A parseable example is [`schemas/examples/generated-files-report-v1.example.json`](../../../schemas/examples/generated-files-report-v1.example.json).

The report includes the root output discriminator and version, skill ID/version, outcome/reason, summary and detailed coverage, immutable knowledge revision, assumptions, artifacts, applied guidance, omitted guidance, and suppression. It never includes findings or overwrite/delete/rename instructions.

Consumers MUST validate the whole document against the published schema and semantic invariants before materializing any file. Validation and staging are atomic and fail closed. Consumers MUST also enforce their own filesystem symlink policy, destination non-existence, byte-size limits, and normalized ID-range policy independently of this model-produced report.
