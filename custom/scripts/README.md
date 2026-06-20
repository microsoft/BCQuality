# custom/scripts

CURABIS shared PowerShell tooling, fetched by `Setup-CurabisAppSource.ps1` into each
project's `scripts\` (or `Scripts\`) folder.

- **Invoke-CurabisEval.ps1** — general "hill climbing" quality eval. Compiles every app
  with the project's own analyzers and emits a score (errors = hard fail; warnings lower it
  on a soft curve), logged to `.eval\history.jsonl`. Run it, change one thing, run it again.
  - `pwsh -File scripts\Invoke-CurabisEval.ps1`
  - `pwsh -File scripts\Invoke-CurabisEval.ps1 -FailUnder 0.5`   (CI gate)

- **Invoke-CurabisEvidence.ps1** — enforces "cite or flag". Validates that every citation
  in a saved review/triage report (knowledge files + `CURABIS-*` rule codes) actually
  exists. Fails on hallucinated citations.
  - `pwsh -File scripts\Invoke-CurabisEvidence.ps1 -ReportPath review.md`
