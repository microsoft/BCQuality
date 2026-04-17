# BCQuality

Quality skills and knowledge for Business Central development.

BCQuality is a curated knowledge base and skills library for Business Central. It provides structured, machine-readable guidance that development agents and tools can consume — establishing a consistent quality bar across tooling and teams.

## What's in this repo

BCQuality contains **knowledge** and **skills**. It does not contain agents. Agents that consume BCQuality ship with [AL-Go](https://github.com/microsoft/AL-Go) and other orchestrators.

### Knowledge files

Atomic markdown files with YAML frontmatter. Each file covers one concern — one thing an agent would cite when reviewing or generating code. Knowledge files live in two layers:

- **`/microsoft/`** — Microsoft-endorsed layer.
  - `/microsoft/knowledge/` — Platform guardrails, official guidance.
  - `/microsoft/skills/` — Microsoft-endorsed action skills.
- **`/community/`** — BC community layer.
  - `/community/knowledge/` — Community patterns and shared guidance.
  - `/community/skills/` — Community-contributed action skills.

- **`/custom/`** — Partner- and customer-specific overrides. Empty by default; populated in forks.
  - `/custom/knowledge/` — Organization-specific knowledge files.
  - `/custom/skills/` — Organization-specific action skills.

All three layers are enabled by default when an agent consumes BCQuality. Content can be promoted from Community to Microsoft-endorsed once it proves itself — this is a first-class concept, not an afterthought.

### Skills

Skills define how agents consume knowledge. They come in two flavors:

- **Meta-skills** (`/skills/`) — the three globally shared skills that bootstrap every interaction with BCQuality:
  1. **Schema + Use** (READ) — how to read a knowledge file: interpret frontmatter, parse sections, understand layer precedence. This is the consumer's reference — any agent or skill that reads knowledge files depends on it.
  2. **Action Skill** (DO) — the template every action skill follows. Defines the four-step pattern (Source → Relevance → Worklist → Action) and the structured output format that orchestrators expect. This is the skill author's reference.
  3. **New Knowledge** (WRITE) — how to author a valid knowledge file. References Schema + Use for the format specification and adds authoring rules (atomicity, section guidance). This is the contributor's reference.

  Schema + Use and New Knowledge are deliberately separate: one is the reader's contract, the other is the writer's guide. New Knowledge depends on Schema + Use but does not duplicate it.

- **Action skills** — concrete skills that follow the Action Skill template to do real work (review code, audit telemetry, etc.). Action skills live inside the layers that own them (`/microsoft/skills/`, `/community/skills/`).

### Agent bootstrapping

Agents discover BCQuality through `/skills/`. An orchestrator (such as AL-Go) points the agent at the repository, and the agent reads the meta-skills in `/skills/` first to learn how to interpret knowledge files, follow the action-skill pattern, and produce output the orchestrator can consume. The meta-skills are the entry point — no prior knowledge of BCQuality's structure is required.

## Knowledge file format

Every knowledge file is a markdown file with mandatory YAML frontmatter. Files target under 100 lines (ideal under 50). If two ideas would share a file, split them.

### Frontmatter schema (v1)

```yaml
---
bc-version: [26..28]                   # BC versions this applies to
domain: performance                     # security | performance | ux | telemetry | ...
keywords: [query, filtering, partial]   # free-text tags for retrieval
technologies: [al]                      # al | javascript | powershell | ...
countries: [w1]                        # ISO codes, or [w1]
application-area: [all]                 # finance | manufacturing | jobs | [all]
---
```

All six fields are required. The schema is locked — changes require a PR approved by both maintainers.

### Sections

Every knowledge file must contain a `## Description` section. The following sections are optional but recommended:

- **`## Best Practice`** — the recommended approach
- **`## Anti Pattern`** — what to avoid and why

Code examples belong in separate files, not in the knowledge file itself. Knowledge files must not contain fenced code blocks.

## Scope

BCQuality covers Business Central broadly — the application domains it supports, the technologies used to extend it, and the practices that keep implementations healthy. The scope includes:

- **Business Central domains** — Finance, Supply Chain Management, Manufacturing, Jobs, Warehousing, Service, and the many other functional areas BC covers. Domain knowledge helps agents understand the business context they are working in.
- AL language patterns and anti-patterns
- PowerShell scripting for BC
- Pipelines (AL-Go, GitHub Actions)
- Business Central APIs
- Power Platform integration
- Telemetry and KQL
- AppSource lifecycle

A BC developer's actual job spans all of this, and BCQuality reflects that.

## How agents consume BCQuality

Action skills follow a four-step pattern:

1. **Source** — which knowledge folders and tags to search
2. **Relevance** — filter by frontmatter (version, technology, country, area)
3. **Worklist** — narrow from N candidates to the M that apply to the current task
4. **Action** — apply the relevant knowledge and produce structured output

Every action skill produces output in a common format that orchestrators can consume without skill-specific parsing. The format includes findings (what the skill observed), references (which knowledge files informed each finding), and confidence signals. This contract is defined in the Action Skill meta-skill so that orchestrators and action skills remain independently evolvable.

The meta-skills in `/skills/` define this pattern. Every concrete action skill follows it.

For the end-to-end flow — from orchestrator trigger through to how output reaches developers — see [agent-consumption.md](agent-consumption.md).

## Repository structure

```
├── /skills/              # Global meta-skills (Schema+Use, Action Skill, New Knowledge)
├── /.github/             # Actions and workflows
├── /microsoft/           # Microsoft-endorsed layer
│   ├── /knowledge/       # Knowledge files by domain
│   │   └── /<domain>/
│   └── /skills/          # Microsoft-endorsed action skills
├── /community/           # BC community layer
│   ├── /knowledge/       # Knowledge files by domain
│   │   └── /<domain>/
│   └── /skills/          # Community action skills
├── /custom/              # Partner/customer-specific overrides (empty; populated in forks)
│   ├── /knowledge/
│   └── /skills/
```

## Contributing

Contributions are welcome. Before submitting a PR:

1. Read the knowledge file format above — frontmatter and sections are validated by CI.
2. Keep files atomic: one concern per file, under 100 lines.
3. Target your contribution to the right layer — most community contributions go in `/community/knowledge/`.

CI runs validation on every PR. If your knowledge file has schema violations, missing sections, code blocks, or exceeds 100 lines, the check will fail with a clear error message.

## License

[MIT](LICENSE)
