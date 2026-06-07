# Custom layer

This folder holds partner- and customer-specific knowledge and action skills: content that applies to your organization but is not appropriate for the shared Microsoft or Community layers. It follows exactly the same formats as the other layers, so the consuming agent loads it automatically alongside `/microsoft/` and `/community/`.

## Structure

```
custom/
├── knowledge/    # Knowledge files (same format as /microsoft/knowledge/)
└── skills/       # Action skills (Source -> Relevance -> Worklist -> Action -> Output)
```

Knowledge files in `/custom/knowledge/` follow the frontmatter schema and section rules in [`/skills/read.md`](../skills/read.md) and [`/skills/write.md`](../skills/write.md). Action skills in `/custom/skills/` follow the contract in [`/skills/do.md`](../skills/do.md).

## What is here

This layer was seeded by migrating the Business Central AL assets from the `community-integration` project into BCQuality formats.

### Knowledge (`custom/knowledge/`)

| Domain | Articles | Covers |
|---|---|---|
| `integration` | 15 | The modern integration pattern catalog from the BCTechDays 2026 "Designing Modern Integrations" session: staging through the Integration Message, inbound and outbound idempotency, polling framing records, the single staging endpoint, the wait-loop anti-pattern, Business Event versioning and payload safety, correlation propagation, long-running 202 / status-url flows, staged pipelines, batching trade-offs, error classification, manual resolution, and the hard anti-patterns. |
| `api` | 2 | Exposing BC entities as API pages for external agents, and least-privilege MCP tool surfaces. |
| `operations` | 2 | SaaS point-in-time restore limits, and inspecting the AL runtime during a debug session. |
| `process` | 1 | Mapping each feature to a reserved AL object ID range during planning. |
| `performance` | 1 | Profiling before optimising with the built-in Performance Profiler. |

Most integration articles ship `.good.al` / `.bad.al` companion samples.

### Skills (`custom/skills/`)

| Folder | Skills | Notes |
|---|---|---|
| `review/` | 14 | Net-new AL reviewers and auditors: multi-tenancy, permission-set, event-subscriber, obsolescence, integration-pattern, upgrade, code-quality, readability, table-refactor, performance, translation, AppSource, and major-release-readiness. Plus `al-extended-review`, a super-skill that composes the six net-new domain reviewers so they dispatch as a group alongside the platform `al-code-review`. |
| `testing/` | 10 | The test agent suite (write, validate, run, coverage validate and enforce, user-guide tests, web-client run) plus the release-audit test-guide generator, Page Scripting e2e planning, and Copilot test-driven development. |

## How to use

Fork or clone BCQuality into your own repository and add your content here, or adapt the migrated content above. The reviewers cite the knowledge files by path, so a finding always points the author at the rule that backs it. When agents consume BCQuality, the custom layer is loaded alongside Microsoft and Community, and its higher layer precedence means your overrides win on conflict.
