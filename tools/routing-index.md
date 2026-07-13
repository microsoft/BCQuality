# Routing index

The **routing index** (`routing-index.json`) is the orchestrator-facing companion
to the [knowledge index](../tools/Build-KnowledgeIndex.ps1). Where the knowledge
index lets the *agent* enumerate candidate articles inside the CLI run, the
routing index lets the *orchestrator* decide — deterministically, before any
tokens are spent — which review domains a PR touches and which articles back each
detection signal.

It exists to retire a shadow catalog. The PR-review orchestrator historically
carried a hand-written ~28-token regex catalog (`$BcqSignalCatalog`) hardcoded in
`Invoke-CopilotPRReview.ps1`. That catalog never read the `domain` / `keywords`
front-matter every article already declares, so its blind spots were exactly
where findings were missed. The routing index moves that knowledge into content:
signals and their domains are compiled *from articles*, so a new article — even a
community one — becomes routable the moment it lands, with no orchestrator edit.

## What it is (and is not)

- **It is** an orchestrator-side artifact. It is consumed by `Build-ReviewManifest`
  (behind the `BCQ_INDEX_V2` flag) to score per-domain suspicion and shortlist
  candidate articles. It is **never** fed into the CLI prompt, so it can be richer
  than the lean knowledge index without inflating the token-paid path.
- **It is not** committed. Like `knowledge-index.json`, it is a runtime artifact
  rebuilt over each consumer's already-pruned clone (`tools/Build-RoutingIndex.ps1`)
  and is `.gitignore`d.
- **It is not** the knowledge index. The two are siblings built from the same
  front-matter; the knowledge index is agent-replayed, the routing index is not.

## How signals are compiled

`Build-RoutingIndex.ps1` composes signals from three sources, highest precision
first:

1. **Seed** (`tools/routing-seed.json`) — the migrated legacy catalog. Ingested
   first so routing recall is never below what the old hardcoded catalog caught.
   Each seed signal is then enriched with **every** article whose (normalized)
   domain matches, so recall is complete-by-construction rather than limited by a
   hand-maintained token→article map.
2. **Article-declared** (`signals:` front-matter, optional) — the authored,
   highest-precision path. Use it when an article catches a specific AL construct
   the seed does not name.
3. **Keyword-derived** (`-IncludeKeywordSignals`, off by default) — soft signals
   from article keywords at reduced weight. Off by default because keywords are
   lowercase-kebab and match noisily, and the online-evals feedback shows the agent
   already over-fires. Prefer authored `signals:` for precision.

## The optional `signals:` front-matter block

Knowledge articles may declare an **optional** `signals:` block. When omitted, the
article is still routed via the seed + its domain (fully back-compatible — no
existing article must change). Each entry is either a bare token string or a
mapping:

```yaml
domain: performance
keywords: [lock, readonly, isolation]
signals:
  - LockTable                     # bare token -> pattern \bLockTable\b, domain = article domain
  - token: ReadIsolation
    pattern: '\bReadIsolation\b'  # explicit regex (optional)
    domain: performance           # override domain (optional; normalized)
```

- `token` (required) — stable signal id; need not be an AL identifier verbatim.
- `pattern` (optional) — regex matched against **added** diff lines. Defaults to
  `\b<token>\b`.
- `domain` (optional) — defaults to the article's `domain`, then normalized.

The front-matter validator (`.github/scripts/validate_frontmatter.py`, rule R24)
enforces this shape; `signals` is the only optional key in the otherwise-closed
knowledge key set.

## Domain normalization

Three vocabularies describe the same domains and must be reconciled:

| Front-matter (article) | Orchestrator (`$DomainMap`) | Feedback (`byDomain`) |
|------------------------|-----------------------------|-----------------------|
| `ui`                   | `Accessibility`             | `accessibility`       |
| `error-handling`       | `Error Handling`            | —                     |
| `web-services`         | `Web Services`              | —                     |
| `breaking-changes`     | `Breaking Changes`          | —                     |
| `events` / `interfaces`| `Events` / `Interfaces`     | —                     |
| `telemetry`            | `Privacy` (folded)          | —                     |

`routing-seed.json → domain-normalization` maps front-matter domains to the
orchestrator's canonical TitleCase taxonomy so seed signals (authored in that
taxonomy) attach to the right articles. `appsource` is a documented **pass-through**
domain (indexed, but has no review leaf skill, so it routes only via the
`al-code-review` super-skill). The CI guard fails if a new front-matter domain
appears that is neither normalized nor a pass-through, keeping the map complete as
content grows.

## Layer-replication story

The whole process is open and per-layer. A partner running the pipeline against
their own `community/` or `custom/` layers gets routing for free: their articles'
front-matter (and any `signals:` they add) compile into the same index by the same
generator. No Microsoft-only data is required to build Tier 1. The later Tier 2
feedback overlay (precision weights distilled from online evals) is a separate,
aggregate-only artifact that multiplies onto these Tier-1 weights — each layer
carries its own overlay produced from its own feedback.

## Files

| File | Role |
|------|------|
| `tools/Build-RoutingIndex.ps1`       | Generator (scan layers → `routing-index.json`) |
| `tools/routing-seed.json`            | Content-owned seed: migrated catalog + domain-normalization + object-kind hints |
| `tools/routing-index.schema.json`    | JSON Schema for the compiled artifact |
| `.github/scripts/Test-RoutingIndex.ps1` | CI guard (determinism, recall floor, no orphans, normalization complete) |
| `.github/workflows/knowledge-index.yml` | Runs both index guards on PR/push to main |
