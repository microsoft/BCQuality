# Authoring-assist: `Suggest-ArticleSignals.ps1`

> **Status:** first-class BCQuality tool. It **suggests only** — it never edits an
> article. It runs on demand from the CLI *and* as a **non-blocking advisory** on
> every PR that adds or modifies a knowledge article (see
> [Automated advisory](#automated-advisory-ci)). Suggestions are human-reviewed;
> R29 + CI + CODEOWNERS remain the gate.

## Why

Routing quality is capped by how well each knowledge article's front-matter
describes the code it catches. The orchestrator scores a PR diff against
per-article `signals:`; an article
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

1. **Proposed `signals:` block** — the highest-value constructs from the article's
   own samples/prose. Constructs are
   ranked by: keyword-backed (+3), appears in the `.bad.al` anti-pattern sample
   (+2), seen in an actual sample (+1), frequency. Sample-local scaffolding
   (procedure/object names) and structural AL vocabulary (types, control-flow,
   object kinds) are filtered out. When an **optional** routing seed is present
   (`-SeedPath`, or `tools/routing-seed.json` if the routing-index thread has
   landed one), constructs already routed to the article's domain are de-duped
   out; without a seed every strong construct is offered.
2. **Suppressor (`effect: suppress`) proposals** — when an article exists to say a
   construct is **not** a violation of its domain (detected from the title/basename
   and prose, e.g. `page-display-is-not-a-privacy-concern`), its constructs are
   proposed as `effect: suppress` (mapping form) instead of raise. A suppress hit
   *dampens* the domain score in the orchestrator rather than raising it, directly
   attacking the over-firing (precision) problem. Prohibitions (`do-not-…`,
   `avoid-…`) are explicitly **excluded** — those describe a real violation.
3. **Domain-mismatch flag** *(seed-only; dormant without a seed)* — when ≥2 of an
   article's sample constructs are known
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

# Exact-match scoping used by the automated advisory (repo-relative paths)
tools/Suggest-ArticleSignals.ps1 -ChangedFiles microsoft/knowledge/performance/avoid-commit-inside-loops.md

# Only the high-value cases (zero-signal domains, suppressors, mismatch/applicability)
tools/Suggest-ArticleSignals.ps1 -OnlyGaps

# Samples-only (ignore article prose)
tools/Suggest-ArticleSignals.ps1 -NoProse

# Machine-readable (the advisory + feedback contract)
tools/Suggest-ArticleSignals.ps1 -AsJson

# Render a JSON report into the PR advisory comment body
tools/Suggest-ArticleSignals.ps1 -ChangedFiles <paths> -AsJson > report.json
tools/New-AuthoringAssistComment.ps1 -JsonPath report.json
```

Key parameters: `-Top <n>` (max signals per article, default 3), `-ChangedFiles`
(exact repo-relative paths), `-NoProse`, `-BCQualityRoot`, `-SeedPath`.

## Automated advisory (CI)

On every PR that touches `**/knowledge/**/*.md`, a **non-blocking** advisory
comment proposes the missing routing head-matter for the changed articles. It
never fails a check; applying a suggestion is optional and human-reviewed.

Three workflows implement it:

| Workflow | Role |
| --- | --- |
| `.github/workflows/authoring-assist.yml` | Unprivileged intake on `pull_request` (path-filtered); saves PR metadata. |
| `.github/workflows/authoring-assist-runner.yml` | Trusted `workflow_run` companion. A read-only `review` job runs the **trusted-base** tool + renderer over the PR-head article text (enriched with the trusted routing seed only if one is present); a separate `publish` job holds `pull-requests: write` and upserts the single advisory comment. |
| `.github/workflows/authoring-assist-selftest.yml` | Runs `Test-SuggestArticleSignals.ps1` against this repo on changes to the tool/renderer. |

The `pull_request` → `workflow_run` split lets the advisory comment on **fork
PRs** without exposing a write-scoped token to the job that reads untrusted PR
content. The tool is a deterministic parser — it never executes AL or PR content.

## JSON contract & feedback metadata

`-AsJson` is a stable contract (`schemaVersion`, `toolVersion`). Every proposal
carries a `suggestionId` — a deterministic hash of `articlePath + token + effect
+ toolVersion` — so feedback can be correlated back to the exact suggestion.

`New-AuthoringAssistComment.ps1` renders that JSON into the advisory comment and
embeds machine-readable markers:

```html
<!-- authoring-assist-advisory -->                 top anchor (idempotent upsert)
<!-- aa:meta schema="1.0" tool="1.0.0" generated="..." articles="N" -->
<!-- aa:article path="..." domain="..." effect="raise|suppress"
                suppressor="true|false" suggestions="id1,id2,..." -->
```

Each comment also carries a reaction footer (👍 useful · ❤️ especially valuable ·
👎 wrong). These markers + reactions are the input to the **feedback harvester**
in `BC-ALAgentsInternal`, which measures suggestion **acceptance** (did the author
apply the proposed `signals:`?) and sentiment. BCQuality emits only the
deterministic markers; the harvest/aggregation is internal and reads BCQuality via
the GitHub API — a downward dependency that keeps the graph acyclic.

## Guardrails (why it only suggests)

`domain`/`signals` are precision-critical and human-reviewed. Silent auto-population
would inject the same noise we're trying to remove and would bypass CODEOWNERS
review. So the tool emits a proposal an author eyeballs and adds via a normal PR;
[`validate_frontmatter.py` R29](../.github/scripts/validate_frontmatter.py) + CI +
human review remain the gate. Both proposed bare-token (raise) and mapping-form
(`effect: suppress`) blocks satisfy R29 as-is.

## Relationship to the feedback-driven engine (Tier-2)

This is the **offline/static (Tier-1)** engine: it proposes signals from an
article's own samples and prose. A complementary **feedback-driven (Tier-2)**
engine in `BC-ALAgentsInternal` closes the loop — it harvests the advisory
comments' feedback metadata (acceptance + reactions, keyed by `suggestionId`) and
mines aggregate PR signals to refine suggestions. It emits aggregate suggestions
only and reads BCQuality via the GitHub API, so the dependency still points
downward (no cycle).
