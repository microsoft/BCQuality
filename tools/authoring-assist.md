# Authoring-assist: `Suggest-ArticleSignals.ps1` (prototype)

> **Status:** offline/on-demand **prototype**. It **suggests only** — it never edits
> an article. The eventual goal (after team agreement) is to run it as a
> **non-blocking advisory** on every BCQuality PR. This doc describes the prototype.

## Why

Routing quality is capped by how well each knowledge article's front-matter
describes the code it catches. The orchestrator scores a PR diff against
per-article `signals:` (see [`routing-index.md`](./routing-index.md)); an article
with no signal for its domain is only reachable via the expensive catch-all pass.

At prototype time **0 of ~207 articles declared an explicit `signals:` block** and
**5 review domains had zero detection signals** (Style, Breaking Changes,
Interfaces, Testing, appsource ≈ 22% of the corpus). Those gaps won't be closed by
hand at scale, and hand-authoring `signals:` correctly is exactly the precision-
critical work we don't want to guess at. This tool lowers that authoring cost.

## What it does

For each article it reads the article's own co-located `good`/`bad` `.al` samples
plus its front-matter, extracts candidate AL constructs, and emits:

1. **Proposed `signals:` block** — the highest-value constructs that are *not*
   already routed to the article's domain by `routing-seed.json`. Constructs are
   ranked by: keyword-backed (+3), appears in the `.bad.al` anti-pattern sample
   (+2), frequency. Sample-local scaffolding (procedure/object names) and
   structural AL vocabulary (types, control-flow, object kinds) are filtered out.
2. **Domain-mismatch flag** — when ≥2 of an article's sample constructs are known
   to the seed and they route to a *different* domain than the article declares
   (e.g. an `events/` article whose sample is all `TryFunction`/`Error`). A soft
   advisory prompting the author to confirm the domain or add a cross-domain signal.

It is **deterministic, offline, and open**: no feedback/telemetry data, so the
community can run it against `community/` and `custom/` layers too.

## Usage

```powershell
# Whole corpus, human-readable report
tools/Suggest-ArticleSignals.ps1

# On-demand, scoped to a folder or a single article (path substring match)
tools/Suggest-ArticleSignals.ps1 -Path knowledge/style
tools/Suggest-ArticleSignals.ps1 -Path avoid-commit-inside-loops

# Only the high-value cases (zero-signal domains + mismatch flags)
tools/Suggest-ArticleSignals.ps1 -OnlyGaps

# Machine-readable (for a future automated PR advisory to consume)
tools/Suggest-ArticleSignals.ps1 -AsJson
```

Key parameters: `-Top <n>` (max signals per article, default 3), `-BCQualityRoot`,
`-SeedPath`.

## Guardrails (why it only suggests)

`domain`/`signals` are precision-critical and human-reviewed. Silent auto-population
would inject the same noise we're trying to remove and would bypass CODEOWNERS
review. So the tool emits a proposal an author eyeballs and adds via a normal PR;
[`validate_frontmatter.py` R24](../.github/scripts/validate_frontmatter.py) + CI +
human review remain the gate. Proposed bare-token blocks satisfy R24 as-is.

## Relationship to the feedback-driven engine (later, Tier-2)

This is the **offline/static (Tier-1)** engine. A complementary **feedback-driven
(Tier-2)** engine — mining `findings.json` for trigger/suppressor/new-article
suggestions — lives in `BC-ALAgentsInternal`, emits aggregate suggestions only, and
is out of scope for this open prototype.

## Path to automation (not yet built)

`-AsJson` output is shaped for a future GitHub Action that posts the suggestions as
a **non-blocking advisory comment** on PRs that add/modify knowledge articles. That
step is deliberately deferred until the team agrees the suggestions are good enough.
