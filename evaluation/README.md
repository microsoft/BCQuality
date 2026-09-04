# AL review evaluation

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

## AL development evaluation

`development-fixtures.json` defines end-to-end development requests rather than
prewritten good/bad snippets. Each case declares its execution mode, the
Business Central capabilities it exercises, the knowledge that should shape
the implementation, acceptance criteria, and the real checks an external
runner must perform.

Validate the fixture and capability manifests and prepare opaque requests:

```powershell
pwsh ./tools/Test-DevelopmentFixtures.ps1 -Root . -PrepareDirectory ./.development-evaluation
```

Each request runs `al-development` in a fresh writable AL repository. Cases
may exercise feature, bug, refactor, upgrade, or maintenance mode.
The runner compiles the generated project, runs its tests, invokes the review
quality gate, and stores the resulting implementation report using the opaque
`caseId` from its request, for example `result-case-a1b2c3d4.json`. It keeps the
generated repository available at the wrapper's `workspaceRoot` so scoring can
verify reported changed paths. Score all results with:

```powershell
pwsh ./tools/Test-DevelopmentFixtures.ps1 -Root . -ResultsDirectory ./.development-evaluation
```

The initial fixtures cover setup-backed master data, document header/line
workflows, versioned API integrations, and surgical diagnosis and repair of a
batch-processing bug. The broader capability roadmap lives in
`coverage/development-capabilities.json`.

### Read-only plan guidance

`development-guidance-fixtures.json` evaluates the planning interface used by
specialized orchestrators. It supplies an existing development plan and expects
a referenced set of implementation constraints without any target-repository
changes.

```powershell
pwsh ./tools/Test-DevelopmentGuidanceFixtures.ps1 -Root . -PrepareDirectory ./.development-guidance-evaluation
```

An external runner stores `result-<case-id>.json` beside the generated request
and retains the clean fixture repository at `workspaceRoot`. Score the result
with `-ResultsDirectory`; the scorer verifies knowledge recall and precision
and fails if the planning pass changed the repository.
