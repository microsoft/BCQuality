# AL review evaluation

The evaluation is convention-driven. The harness discovers every `<layer>/skills/review/al-<domain>-review.md` leaf across the enabled `microsoft`, `community`, and `custom` layers. Duplicate domains resolve with `custom > community > microsoft` precedence. For each selected leaf, the harness finds paired knowledge across the same layers, applies the same precedence to duplicate article slugs, selects the first article (by filename) with both `.bad.al` and `.good.al` companions, and derives the expected positive and clean control automatically. Adding a conforming leaf requires no scoring-contract edit.

`review-fixtures.json` contains only global thresholds and optional exceptional overrides. An override may select a different `article`, add context when the generic convention cannot express a scenario, or use an `articles` array when one domain needs explicit regression coverage for several paired articles. Specify either `article` or `articles`, not both. The first selected article retains the stable `<domain>-bad` and `<domain>-good` manifest IDs; additional articles use slug-qualified IDs. Overrides should remain empty in the normal case.

CI also measures selected paired articles against every effective article that
has both AL companions. A changed paired article must be selected by the
domain convention or an override. When adding it would not provide a useful
deterministic regression, add a narrow `coverageWaivers` entry with its exact
article path and a non-empty reason. Waivers are reviewable exceptions, not a
substitute for domain coverage. The generated coverage report includes totals
and per-domain ratios; the ratio is informational, while changed-file coverage
is mandatory.

Model-facing preparation hashes case IDs, neutralizes `Good`/`Bad` object-name tokens, and removes full-line sample comments so neither the article slug, domain, nor expected outcome reveals the answer.

The SCM `articles` override deliberately selects every rule in the initial
functional domain, producing nine positive cases and nine clean controls.
Business context is executable: document/status `TestField` guards,
calculated-revaluation fields, source-transfer base quantities, warehouse
reconciliation steps, and additional-demand promising parameters survive
neutralization. Do not move those preconditions into comments or generic
"posting" helper names; removing them can turn a real defect into a valid
alternative workflow. The clean pairs exercise the supported APIs selected by
the same routing cues, not merely unrelated code that contains no SCM tokens.

The Finance override deliberately covers every paired Finance article, not
only the first filename. Its shared context supplies the target version and
localization but deliberately omits application area, as production callers
often do. Finance applicability must come from its source-surface gate, not
an artificial evaluation-only area hint. Scenario prerequisites live in
executable AL: the document-balance cases check the template setting, and the
VAT cases encode the imported net/VAT/gross totals and applicable VAT mode.
Do not move these prerequisites into comments that preparation removes.
Clean samples also retain supported operational edits, temporary ledger/set
buffers, legitimate entry-number APIs, and reads of individual shortcut
dimensions so these exceptions are exercised rather than blanket-excluded.

## Validate the corpus

```powershell
pwsh ./tools/Test-ReviewFixtures.ps1 -Root .
```

This credential-free check proves every selected leaf maps to a same-named knowledge domain with at least one complete AL sample pair and that all configured overrides are valid.

To reproduce the changed-file gate and emit the same measurable report as CI:

```powershell
git diff --name-only origin/main...HEAD | Set-Content .changed-paths.txt
pwsh ./tools/Test-ReviewFixtures.ps1 -Root . -ChangedPathsFile .changed-paths.txt -CoverageReportPath .coverage.json
```

## Run a fast-model evaluation

1. Prepare neutral inputs:

   ```powershell
   pwsh ./tools/Test-ReviewFixtures.ps1 -Root . -PrepareDirectory ./.evaluation-run
   ```

   This is also the CI path. It derives all cases, builds the current index, requires the convention-selected article to rank naturally into the candidate cutoff, and prepares the neutral requests.

2. For a fast/small model, use one fresh invocation per `request-case-*.json`. Each request embeds the exact leaf instructions, that domain's candidate index rows with authoritative paths, and one opaque case. The model opens only matching articles and copies finding IDs from `candidateArticles[].path`. Save each response with the matching `result-case-*.json` name in the same directory.

  `request-<domain>.json` files provide optional leaf batches containing every selected case for that domain and identify the selected layer-owned skill path; save those as `result-<domain>.json`. A normal convention-selected domain has one bad/good pair, while an `articles` override contributes one pair per listed article. Directory scoring prefers `result-case-*.json` when present and otherwise falls back to `result-*.json`. `review-request.json` is an optional all-domains stress test for larger models. Neither batch form is the preferred fast-model profile.

3. Save only this result shape:

   ```json
   {
     "cases": [
       {
         "id": "case-a1b2c3d4",
         "findings": [
           { "id": "microsoft/knowledge/appsource/permission-sets-cover-setup-and-usage-without-super.md" }
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
