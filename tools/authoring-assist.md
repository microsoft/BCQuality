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
**and its prose** (inline `` `code` `` spans + fenced ```` ```al ```` blocks), plus
its front-matter, extracts candidate AL constructs, and emits:

1. **Proposed `signals:` block** — the highest-value constructs that are *not*
   already routed to the article's domain by `routing-seed.json`. Constructs are
   ranked by: keyword-backed (+3), appears in the `.bad.al` anti-pattern sample
   (+2), seen in an actual sample (+1), frequency. Sample-local scaffolding
   (procedure/object names) and structural AL vocabulary (types, control-flow,
   object kinds) are filtered out.
2. **Suppressor (`effect: suppress`) proposals** — when an article exists to say a
   construct is **not** a violation of its domain (detected from the title/basename
   and prose, e.g. `page-display-is-not-a-privacy-concern`), its constructs are
   proposed as `effect: suppress` (mapping form) instead of raise. A suppress hit
   *dampens* the domain score in the orchestrator rather than raising it, directly
   attacking the over-firing (precision) problem. Prohibitions (`do-not-…`,
   `avoid-…`) are explicitly **excluded** — those describe a real violation.
3. **Domain-mismatch flag** — when ≥2 of an article's sample constructs are known
   to the seed and they route to a *different* domain than the article declares
   (e.g. an `events/` article whose sample is all `TryFunction`/`Error`). A soft
   advisory prompting the author to confirm the domain or add a cross-domain signal.
   Skipped for suppressor articles, which deliberately reference other domains.
4. **Applicability note** — flags samples/prose that use a JavaScript control add-in
   when `technologies` omits `javascript`. Small but concrete; kept minimal because
   the technologies vocabulary is tiny (`al`/`javascript`).
5. **Keyword suggestions** — strong proposed constructs not already present in the
   article's `keywords` list, surfaced as an advisory "consider adding".

**Prose mining** matters for the ~17% of articles that ship no `.al` samples at all
(including most suppressor articles): their constructs are recovered from the prose
and marked `proseOnly` so a reviewer knows the weaker provenance. Use `-NoProse` to
restrict the source to samples only.

It is **deterministic, offline, and open**: no feedback/telemetry data, so the
community can run it against `community/` and `custom/` layers too.

## Usage

```powershell
# Whole corpus, human-readable report
tools/Suggest-ArticleSignals.ps1

# On-demand, scoped to a folder or a single article (path substring match)
tools/Suggest-ArticleSignals.ps1 -Path knowledge/style
tools/Suggest-ArticleSignals.ps1 -Path avoid-commit-inside-loops

# Only the high-value cases (zero-signal domains, suppressors, mismatch/applicability)
tools/Suggest-ArticleSignals.ps1 -OnlyGaps

# Samples-only (ignore article prose)
tools/Suggest-ArticleSignals.ps1 -NoProse

# Machine-readable (for a future automated PR advisory to consume)
tools/Suggest-ArticleSignals.ps1 -AsJson
```

Key parameters: `-Top <n>` (max signals per article, default 3), `-NoProse`,
`-BCQualityRoot`, `-SeedPath`.

## Guardrails (why it only suggests)

`domain`/`signals` are precision-critical and human-reviewed. Silent auto-population
would inject the same noise we're trying to remove and would bypass CODEOWNERS
review. So the tool emits a proposal an author eyeballs and adds via a normal PR;
[`validate_frontmatter.py` R24](../.github/scripts/validate_frontmatter.py) + CI +
human review remain the gate. Both proposed bare-token (raise) and mapping-form
(`effect: suppress`) blocks satisfy R24 as-is.

## Relationship to the feedback-driven engine (later, Tier-2)

This is the **offline/static (Tier-1)** engine. A complementary **feedback-driven
(Tier-2)** engine — mining `findings.json` for trigger/suppressor/new-article
suggestions — lives in `BC-ALAgentsInternal`, emits aggregate suggestions only, and
is out of scope for this open prototype.

## Path to automation (not yet built)

`-AsJson` output is shaped for a future GitHub Action that posts the suggestions as
a **non-blocking advisory comment** on PRs that add/modify knowledge articles. That
step is deliberately deferred until the team agrees the suggestions are good enough.
