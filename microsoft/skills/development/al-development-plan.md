---
kind: action-skill
id: al-development-plan
version: 1
title: AL development plan guidance
description: Produces a read-only BCQuality knowledge bundle for an existing Business Central AL development plan.
inputs: [development-plan, repository]
outputs: [development-guidance-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL development plan guidance

Selects the BCQuality knowledge that should constrain an existing AL development plan. It does not implement, edit, stage, commit, or publish anything in the target repository. Repository-specific orchestrators can consume this skill before their own test and implementation phases while retaining ownership of workflow, tooling, and delivery.

Both a readable `repository` and a non-empty `development-plan` are required. The plan may be structured data or text, but it must identify the intended change. Return `not-applicable` without changing files when either input is absent or the repository is not an AL project.

The caller supplies its existing plan, not a request to generate one. Consumer-specific formats must be normalized by the consumer before invocation. This skill does not interpret issue records, continuation markers, batons, retries, or workflow state. A serialized document containing plan metadata and a markdown body is acceptable when it states the intended change, affected surfaces, proposed approach, test strategy, and acceptance criteria. Missing details remain unknown; do not invent them.

## Source

Read the BCQuality knowledge index once, using the external path supplied by Entry when present. If no index is available, use READ's path-based discovery across enabled layers; inability to read the corpus is `failed`, not `no-knowledge`. Use entries from every enabled layer and domain. The index supplies candidate paths, applicability dimensions, keywords, titles, and descriptions; it never substitutes for opening selected articles in full.

Inspect the target repository read-only for `app.json`, affected files and symbols named by the plan, relevant tests, permission sets, dependencies, target/runtime versions, countries, application areas, and repository conventions. Do not create scratch or generated files inside the target repository.

## Relevance

Apply READ's matching semantics using:

- `bc-version` from the plan, target application, or supplied context; for upgrades, distinguish source and target versions.
- `technologies` from the affected files, beginning with `[al]`.
- `countries` from the plan, `app.json`, or workspace configuration.
- `application-area` from the plan and affected objects.

When a dimension cannot be resolved, retain conditionally applicable candidates only when they can materially constrain the plan. Record the dimension in `context.unknown` and explain it in `unresolved`; do not silently treat it as a match.

## Worklist

1. Read the supplied plan for its request summary, development kind, assumptions, root cause or design intent, affected files and symbols, proposed changes, test strategy, and acceptance criteria. Preserve its intent; do not generate a replacement plan. If kind is not explicit, classify the stated intent: new or expanded behavior is `feature`, a defect correction is `bug`, behavior-preserving restructuring is `refactor`, migration is `upgrade`, and other bounded work is `maintenance`. Do not redesign the consumer's workflow.
2. Build retrieval vocabulary from the plan and confirmed repository symbols. Give exact object types, properties, methods, analyzers, errors, and affected domains more weight than broad business nouns.
3. Search the index in separate passes:
   - data ownership, keys, setup, numbering, validation, transactions, and upgrade;
   - behavior, events, interfaces, errors, permissions, privacy, and telemetry;
   - pages, reports, APIs, integrations, localization, and accessibility;
   - tests, analyzers, packaging, and deployment constraints.
4. Add an article when its keywords or indexed topic match a concrete planned change, affected symbol, acceptance criterion, or validation obligation. Applicability alone is not enough.
5. Open every selected article in full. Read any referenced `.good.*` and `.bad.*` sibling needed to make the constraint concrete. Never cite an index row that was not opened.
6. Resolve contradictory normative guidance with READ's layer precedence and record losing candidates in `suppressed`.
7. Check the resulting worklist across the whole plan. A bug fix may require testing, data, performance, and upgrade guidance at once; a feature plan may require security and lifecycle constraints that are not named in its title.

Keep the worklist focused. Do not include generic engineering advice, an entire domain, or an article that would not change implementation or validation.

## Action

For each worklist article:

1. Copy its exact path and optional commit SHA.
2. State `used-for` as the concrete plan decision or affected surface.
3. Translate its normative Best Practice and Anti Pattern into short implementation constraints without adding facts or weakening conditions.
4. Include only opened, existing sibling samples in `sample-paths`.
5. Derive validation considerations only where the plan or selected knowledge requires observable evidence. Describe the evidence to obtain; do not claim it already exists or passed.

Do not change the target repository. Before emitting, verify every knowledge and sample path exists in the live BCQuality checkout and was opened during this run. If reference integrity cannot be established, return `failed` rather than fabricating guidance.

## Output

Return one `development-guidance-report` conforming to DO. `completed` requires that every selected article was opened and faithfully converted into constraints, with no material unresolved applicability. `no-knowledge` means there are no additional applicable BCQuality constraints for this plan; emit empty `knowledge`. It does not mean the work is unsafe or unimplementable, and the consumer can proceed under its ordinary gates. Never add generic or filler guidance to avoid this outcome.

Return `partial` for incomplete evaluation or materially unresolved conditional guidance, naming every gap. Failed retrieval or reference-integrity checks are `failed`, never `no-knowledge`. Consumers own handling of partial, failed, and unresolved results, including clarification and re-enrichment; this read-only interface does not define a universal implementation gate.
