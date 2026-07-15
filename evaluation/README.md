# AL review evaluation

`review-fixtures.json` contains one positive and one clean control for every AL review leaf. Inputs are existing companion samples, but model-facing preparation hashes case IDs, neutralizes `Good`/`Bad` object-name tokens, and removes full-line sample comments so neither the article slug, domain, nor expected outcome reveals the answer.

## Validate the corpus

```powershell
pwsh ./tools/Test-ReviewFixtures.ps1 -Root .
```

This is credential-free and runs in CI. It validates fixture paths, expected article references, unique IDs, and positive/clean coverage for every registered leaf.

## Run a fast-model evaluation

1. Prepare neutral inputs:

   ```powershell
   pwsh ./tools/Test-ReviewFixtures.ps1 -Root . -PrepareDirectory ./.evaluation-run
   ```

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

The committed gate requires full expected recall and no findings on clean controls. `allowedAdditional` in the manifest records known, independently valid overlaps without weakening the required primary finding.
