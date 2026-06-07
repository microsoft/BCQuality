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
| `integration` | 13 | The modern integration pattern catalog: staging through the Integration Message, inbound and outbound idempotency, polling framing records, Business Event versioning and payload safety, correlation propagation, long-running and staged flows, manual resolution, and the hard anti-patterns. |
| `copilot` | 4 | Registering a Copilot capability, calling Azure OpenAI through System.AI, billing type, and authoring a custom agent with the IAgent interfaces. |
| `ux` | 2 | PromptDialog for Copilot Generate UX, and keeping prompt text free of trailing whitespace. |
| `pipelines` | 4 | AL-Go for GitHub CI/CD, settings as the source of truth, environment registration, and headless builds with the AL MCP Server. |
| `security` | 3 | Least-privilege Azure RBAC, Managed Identity over connection strings, and locking environments to an Entra security group. |
| `process` | 3 | Spec-Driven Development: specify before you build, the solution constitution, and mapping features to object ID ranges. |
| `api` | 2 | Exposing BC entities as API pages for external agents, and least-privilege MCP tool surfaces. |
| `operations` | 2 | SaaS point-in-time restore limits, and inspecting the AL runtime during a debug session. |
| `performance` | 1 | Profiling before optimising with the built-in Performance Profiler. |
| `upgrade` | 1 | Gating major version bumps on compatibility testing. |

Many integration, Copilot, and UX articles ship `.good.al` / `.bad.al` companion samples.

### Skills (`custom/skills/`)

| Folder | Skills | Notes |
|---|---|---|
| `review/` | 14 | Net-new AL reviewers and auditors: multi-tenancy, permission-set, event-subscriber, obsolescence, integration-pattern, upgrade, code-quality, readability, table-refactor, performance, translation, AppSource, and major-release-readiness. Plus `al-extended-review`, a super-skill that composes the six net-new domain reviewers so they dispatch as a group alongside the platform `al-code-review`. |
| `testing/` | 10 | The test agent suite (write, validate, run, coverage validate and enforce, user-guide tests, web-client run) plus the release-audit test-guide generator, Page Scripting e2e planning, and Copilot test-driven development. |
| `integration/` | 2 | Validating and reviewing the Azure integration plane (Functions, Service Bus, APIM, Bicep) that BC integrations depend on. |

## How to use

Fork or clone BCQuality into your own repository and add your content here, or adapt the migrated content above. The reviewers cite the knowledge files by path, so a finding always points the author at the rule that backs it. When agents consume BCQuality, the custom layer is loaded alongside Microsoft and Community, and its higher layer precedence means your overrides win on conflict.
