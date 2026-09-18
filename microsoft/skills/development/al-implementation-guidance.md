---
kind: action-skill
id: al-implementation-guidance
version: 1
title: AL implementation guidance
description: Produces focused, read-only BCQuality guidance for the next Business Central AL implementation or validation decision.
inputs: [development-plan, repository, implementation-diff, decision-context, consumed-guidance]
outputs: [implementation-guidance-report]
bc-version: [all]
technologies: [al]
countries: [w1]
application-area: [all]
---

# AL implementation guidance

Selects BCQuality knowledge that can change the consumer's next implementation or validation decision. It is a just-in-time consultation after implementation has begun, not a second plan-enrichment pass.

A readable `repository`, non-empty `development-plan`, current `implementation-diff`, and current `decision-context` are required. The diff may be a patch or structured changed-file/source context, but it must identify exact affected files and current code. Decision context must identify the current phase, next decision, affected symbols, changed AL properties or tokens, tests or acceptance criteria, and stable `decision-key` and `evidence-fingerprint` values. Return `not-applicable` when any required focus input is absent or empty, when the repository is not an AL project, or when current implementation evidence cannot be distinguished from plan intent. Do not invent missing workflow state.

`consumed-guidance` is optional consumer-owned state. Each entry contains an exact article `path`, `decision-key`, `evidence-fingerprint`, and `prior-decision` summary. BCQuality stores no state. An exact path/key/fingerprint match is omitted from `knowledge` and recorded in `deduplication.omitted`; a different decision key or evidence fingerprint is a new consultation surface and the article may be selected again.

This skill never edits source, owns workflow state, runs an implementation or review/fix loop, compiles, deploys, stages, commits, or publishes. The consuming coding agent owns all implementation, tests, retries, review, and delivery.

## Source

Read the BCQuality knowledge index once, using the external path supplied by Entry when present. If no index is available, use READ's path-based discovery across enabled layers; inability to read the corpus is `failed`, not `no-knowledge`. The index is discovery metadata only.

Inspect the supplied repository and implementation evidence read-only. Confirm exact changed and affected AL files, symbols, newly introduced properties and tokens, current tests and acceptance obligations, plan intent, and already-consumed guidance. Do not create scratch or generated files inside the target repository.

## Relevance

Apply READ's matching semantics using resolved target and implementation context. For upgrades, distinguish source and target versions. Retain conditionally applicable candidates only when resolving them could change the next decision. Record unknown dimensions in `context.unknown` and explain their materiality in `unresolved`.

## Worklist

1. Preserve the plan's intent, but derive retrieval vocabulary primarily from the current diff, exact affected files and symbols, changed AL properties and tokens, current phase and decision, tests, acceptance criteria, and validation failures. Do not regenerate or broadly enrich the plan.
2. Check the current surface at deterministic consumer-visible checkpoints: schema or data upgrade; public API, events, or interfaces; permissions; external effects, job queues, or `HttpClient`; telemetry or privacy; UI or page background tasks; and tests. Also consult when the consumer explicitly requests BC-specific guidance for a bounded decision. These are orchestration recommendations, not hidden automatic behavior.
3. Search only domains connected to concrete current evidence. Add an article only when its normative content can change the next implementation or validation decision. Applicability, a broad business noun, or plan membership alone is insufficient.
4. Open every selected article in full. Open only sibling `.good.*` or `.bad.*` samples needed to make the current constraint concrete. Never cite an unopened index row.
5. Resolve contradictory normative guidance with READ's layer precedence and record losing candidates in `suppressed`.
6. Apply stateless deduplication after selection. Omit an article only when a consumed entry's path, decision key, and evidence fingerprint all exactly match this invocation. Record the omitted entry. A changed affected surface or diff fingerprint permits selection again.

Keep the worklist focused on the next decision. Do not return entire domains, generic engineering advice, previously consumed exact matches, or constraints that cannot affect implementation or validation.

## Action

For each worklist article:

1. Copy its exact path and optional checkout SHA.
2. State `used-for` as the concrete current decision or affected surface.
3. Translate only its normative Best Practice and Anti Pattern into faithful constraints.
4. Include only opened, existing sibling samples.
5. Describe validation evidence the consumer should obtain without claiming it has run or passed.

Preserve consumer-supplied plan and implementation evidence pins exactly. Use `unpinned` when the consumer supplied none; do not synthesize hashes. Before emitting, verify every knowledge and sample path exists in the live BCQuality checkout and was opened during this run. Reference-integrity failure is `failed`.

## Output

Return one `implementation-guidance-report` conforming to DO. `completed` requires at least one newly applicable or materially re-applicable article and no material unresolved applicability. `no-knowledge` means no additional applicable constraints for this decision and evidence fingerprint; it does not mean the implementation is safe, correct, complete, or ready to ship.

Return `partial` for incomplete evaluation or materially unresolved applicability, and `failed` for retrieval or integrity failure. Keep every unresolved condition explicit. The consumer decides how to respond and owns edits, tests, retries, final independent review, commits, and delivery.
