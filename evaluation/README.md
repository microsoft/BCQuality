# AL review and guidance evaluation

The evaluation is convention-driven. The harness discovers every `<layer>/skills/review/al-<domain>-review.md` leaf across the enabled `microsoft`, `community`, and `custom` layers. Duplicate domains resolve with `custom > community > microsoft` precedence. For each selected leaf, the harness finds paired knowledge across the same layers, applies the same precedence to duplicate article slugs, selects the first article (by filename) with both `.bad.al` and `.good.al` companions, and derives the expected positive and clean control automatically. Adding a conforming leaf requires no scoring-contract edit.

`review-fixtures.json` contains only global thresholds and optional exceptional overrides. An override may select a different article or add context when the generic convention cannot express a scenario. It should remain empty in the normal case.

Model-facing preparation hashes case IDs, neutralizes `Good`/`Bad` object-name tokens, and removes full-line sample comments so neither the article slug, domain, nor expected outcome reveals the answer.

## Validate the corpus

```powershell
pwsh ./tools/Test-ReviewFixtures.ps1 -Root .
```

This credential-free check proves every selected leaf maps to a same-named knowledge domain with at least one complete AL sample pair and that all configured overrides are valid.

## Run a fast-model evaluation

1. Prepare neutral inputs:

   ```powershell
   pwsh ./tools/Test-ReviewFixtures.ps1 -Root . -PrepareDirectory ./.evaluation-run
   ```

   This is also the CI path. It derives all cases, builds the current index, requires the convention-selected article to rank naturally into the candidate cutoff, and prepares the neutral requests.

2. For a fast/small model, use one fresh invocation per `request-case-*.json`. Each request embeds the exact leaf instructions, that domain's candidate index rows with authoritative paths, and one opaque case. The model opens only matching articles and copies finding IDs from `candidateArticles[].path`. Save each response with the matching `result-case-*.json` name in the same directory.

  `request-<domain>.json` files provide optional two-case leaf batches and identify the selected layer-owned skill path; save those as `result-<domain>.json`. Directory scoring prefers `result-case-*.json` when present and otherwise falls back to `result-*.json`. `review-request.json` is an optional all-domains stress test for larger models. Neither batch form is the preferred fast-model profile.

3. Save only this result shape:

   ```json
   {
     "cases": [
       {
         "id": "case-a1b2c3d4",
         "findings": [
           { "id": "microsoft/knowledge/appsource/object-affixes-prevent-collisions.md" }
         ]
       }
     ]
   }
   ```

   Include every case. A clean control has an empty `findings` array.

4. Score all per-leaf results together:

   ```powershell
   pwsh ./tools/Test-ReviewFixtures.ps1 -Root . -ResultsDirectory ./.evaluation-run
   ```

   For a single combined stress-test result, use `-ResultsPath` instead.

The committed gate requires full expected recall, the exact convention-derived article ID, and no findings on clean controls.

## Read-only plan guidance

`development-guidance-fixtures.json` evaluates the planning interface used by
existing workflows. It supplies an existing plan and expects referenced
constraints without target-repository changes. The initial-plan fixture is
anonymized and synthetic: a full document with metadata and a markdown body
covering root cause, proposed fix, affected files, tests, and acceptance
criteria. It is integration-shaped input, not private consumer content, a
continuation checkpoint, or proof that any production consumer is integrated.

### Credential-free contract and scorer coverage

CI validates the manifest, prepares opaque model requests, and runs
deterministic scorer regressions with controlled reports and temporary Git
repositories. These checks cover report shape, outcomes, reference paths, and
the evaluator's pre/post read-only comparison. They do **not** run an agent,
compile AL, run Business Central tests, or establish better code authoring.

Prepare requests in a runner-owned artifact directory outside every target
workspace:

```powershell
$run = Join-Path ([IO.Path]::GetTempPath()) 'bcquality-guidance-run'
pwsh ./tools/Test-DevelopmentGuidanceFixtures.ps1 -Root . -PrepareDirectory $run
```

Preparation is not a model run. A scorer can validate a citation's path and
required fields, but only external agent traces and expert evaluation can
establish that the article was opened and its normative constraints faithfully
applied. Expected knowledge recall/precision is fixture-specific, not a corpus
coverage or authoring capability percentage.

`no-knowledge` means no additional applicable BCQuality constraints, not unsafe
work. It requires empty `knowledge`. Partial evaluation, failed retrieval,
unknown context, and materially unresolved applicability must remain visible
and distinct; they cannot be counted as successful enrichment merely because
the JSON is parseable.

Run the deterministic regression suite without an agent or AL environment:

```powershell
pwsh ./tools/Test-DevelopmentGuidanceEvaluator.ps1
```

### Runner-owned read-only evidence

For an external guidance run, first provision a representative, standalone Git
repository for each manifest case. The runner supplies a JSON workspace map
whose keys are the manifest IDs (not the hashed model IDs) and whose values are
absolute workspace roots. It may pass `-WorkspaceMapPath` during preparation
to bind the generated requests to those roots. The model must not select its
own workspace for scoring.

Capture evidence **before** invoking the agent, with the manifest, workspace
map, and source checkout already finalized:

```powershell
# Runner-selected paths, all outside the targets and BCQuality checkout.
$map = Join-Path $evidenceDirectory 'workspace-map.json'
$baseline = Join-Path $evidenceDirectory 'baseline.json'
pwsh ./tools/Test-DevelopmentGuidanceFixtures.ps1 -Root . `
    -CaptureBaseline -WorkspaceMapPath $map -BaselinePath $baseline

# Retain the printed SHA256 in runner-only state BEFORE agent invocation.
# After the external agent writes result-case-<hash>.json files:
pwsh ./tools/Test-DevelopmentGuidanceFixtures.ps1 -Root . `
    -ResultsDirectory $resultsDirectory -BaselinePath $baseline `
    -BaselineSha256 $preRunDigest
```

`$evidenceDirectory`, `$resultsDirectory`, and `$preRunDigest` are supplied by
the runner; the digest must not be recomputed from potentially modified evidence
after the agent runs. Protect the baseline, digest, evaluator, and invocation
from agent changes. Capture refuses to overwrite an existing baseline. Results
contain only `caseId` and `guidanceReport`; a legacy `workspaceRoot`, if present,
must agree with the independently captured binding and never overrides it.
Missing baselines or digests, malformed reports, and escaped reference paths
fail scoring.

The comparison checks target identity, Git HEAD, refs and index, filesystem
content and stable metadata, including tracked, untracked, ignored files and
empty directories. Committing edits or making an empty commit does not evade
the check. It also compares the actual knowledge checkout and manifest identity.
Targets must have internal Git storage; linked target worktrees, submodules,
sparse checkouts, links/junctions/reparse points, hard links, and alternate data
streams are unsupported and rejected rather than silently excluded. A linked
**knowledge** checkout is supported with its Git storage identity recorded.
Use quiescent, isolated repositories; concurrent changes also fail the gate.

This is before/after evidence, not an OS sandbox or a complete write monitor.
It cannot prove that no transient write was reverted, that articles were opened,
or that constraints are semantically faithful. Reports and generated artifacts
must stay outside all target workspaces and the knowledge checkout. The
regression suite creates and removes its own uniquely named fixture directory;
it does not run against or clean a caller's target.

### External agent/runtime pilot (follow-up)

Consumer uptake and a real before-authoring pilot are not implemented by these
fixtures. The consumer must normalize its normal initial plan, persist guidance
after state initialization, inject it into existing phases, re-enrich on
material changes, and run an independent final review. See
[the integration boundary](../agent-consumption.md#repository-specific-development-orchestrators).

Before claiming improved repairs, run an independent pinned baseline without
enrichment and a matched enriched run. Hold starting code, task, model, tools,
runtime, and gates constant; record actual immutable BCQuality checkout and
policy identities rather than trusting a configured ref. Use that same
recorded checkout for enrichment and final review. Retain external logs,
article-read traces, resulting diffs, compile/test outcomes, and independent
review evidence, including failures, no-knowledge, partial, and unresolved
results. No compile/run or authoring-quality claim follows from the
credential-free checks above.
