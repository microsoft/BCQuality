# AL review evaluation

The evaluation is convention-driven. For every `microsoft/skills/review/al-<domain>-review.md` leaf, the harness finds `microsoft/knowledge/<domain>/`, selects the first article (by filename) with both `.bad.al` and `.good.al` companions, and derives the expected positive and clean control automatically. Adding a conforming leaf requires no scoring-contract edit.

`review-fixtures.json` contains only global thresholds and optional exceptional overrides. An override may select a different article or add context when the generic convention cannot express a scenario. It should remain empty in the normal case.

Model-facing preparation hashes case IDs, neutralizes `Good`/`Bad` object-name tokens, and removes full-line sample comments so neither the article slug, domain, nor expected outcome reveals the answer.

## Validate the corpus

```powershell
pwsh ./tools/Test-ReviewFixtures.ps1 -Root .
```

This credential-free check proves every registered leaf maps to a same-named knowledge domain with at least one complete AL sample pair and that all configured overrides are valid.

## Run a fast-model evaluation

1. Prepare neutral inputs:

   ```powershell
   pwsh ./tools/Test-ReviewFixtures.ps1 -Root . -PrepareDirectory ./.evaluation-run
   ```

   This is also the CI path. It derives all cases, builds the current index, requires the convention-selected article to rank naturally into the candidate cutoff, and prepares the neutral requests.

2. For a fast/small model, use one fresh invocation per `request-case-*.json`. Each request embeds the exact leaf instructions, that domain's candidate index rows with authoritative paths, and one opaque case. The model opens only matching articles and copies finding IDs from `candidateArticles[].path`. Save each response with the matching `result-case-*.json` name in the same directory.

   `request-<domain>.json` files provide optional two-case leaf batches; save those as `result-<domain>.json`. Directory scoring prefers `result-case-*.json` when present and otherwise falls back to `result-*.json`. `review-request.json` is an optional all-domains stress test for larger models. Neither batch form is the preferred fast-model profile.

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
