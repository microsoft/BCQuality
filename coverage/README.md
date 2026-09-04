# Developer knowledge coverage

This directory separates **source coverage** from the knowledge corpus itself.
Microsoft Learn units are inputs to editorial work, not articles to import
one-for-one.

## Files

- `microsoft-learn-developer-catalog.json` is generated source metadata for all
  Microsoft Learn modules tagged with both `dynamics-business-central` and
  `developer`.
- `learn-coverage.json` is the maintained editorial ledger. Units absent from
  this file are unreviewed.
- `development-capabilities.json` tracks whether representative Business
  Central development capabilities have implementation fixtures.

Each tracked unit has a `reviewStatus`:

- `in-progress` — at least one concern has been identified, but editorial
  triage of the unit is not complete.
- `complete` — every relevant concern in the unit has a recorded outcome. A
  complete unit may have no outcomes when it contains no remedial knowledge.

Each concern has one disposition:

- `candidate` — worth authoring or reconciling with existing knowledge.
- `authored` — produced one or more new knowledge articles.
- `covered-existing` — already represented by the linked article.
- `rejected` — fails BCQuality's remedial admission test.
- `deferred` — valid but intentionally postponed, with a rationale.

An authored article does not make its source unit complete automatically. One
unit can contain several independent concerns.

## Update and report

```powershell
pwsh ./tools/Update-LearnCatalog.ps1
pwsh ./tools/Test-LearnCoverage.ps1
```

The catalog updater also accepts `-CatalogPath` for an exported Microsoft Learn
Platform API response. CI validates the committed snapshot and editorial ledger
without network access.
