# BCQuality

Quality skills and knowledge for Business Central development.

BCQuality is a curated knowledge base and skills library for Business Central. It provides structured, machine-readable guidance that development agents and tools can consume — establishing a consistent quality bar across tooling and teams.

## What belongs here

BCQuality is a remedial knowledge base. A file exists because a capable LLM **would get something wrong, or miss something, without it** — not because the topic is important. The admission test for a knowledge file is one question:

> If this file did not exist, would a modern LLM reviewing or generating BC code make a mistake this file would have prevented?

If the answer is no — the advice is generic software-engineering guidance, or the LLM already knows the BC mechanic in question — the file does not belong here, regardless of how sound the content is. A file earns its place by encoding something BC-specific that LLMs demonstrably get wrong: a CodeCop rule number, a platform API whose semantics the training data gets backwards, a non-obvious ordering rule, a BC property whose default is a footgun.

Good fit: "`SetLoadFields` must be called before filters, not after" (non-obvious ordering rule). "`FindSet(true)` takes a LockTable and the two-parameter signature is obsolete" (subtle platform behaviour + outdated training data). "CodeCop AA0233 flags `FindFirst … Next` loops" (rule-specific).

Poor fit: "Use HTTPS instead of HTTP." "Don't hardcode secrets." "Keep transactions short." These are true but any capable LLM already applies them without prompting.

The practical consequence: when a code-review agent flags something it shouldn't have, or misses something it should have caught, the remedy is a new knowledge file. When it already behaves correctly on a topic, no file is needed.

A file that *prevents* a false positive — documenting why a pattern is legitimate so the agent stops flagging it — is as valid as one that catches a defect: negative clarifications are first-class knowledge files. What never belongs is a BC fact hard-coded into a skill. Skills are finders and appliers; knowledge files are what the agent knows. See [`skills/do.md`](skills/do.md) and [`skills/write.md`](skills/write.md).

## What's in this repo

BCQuality contains **knowledge** and **skills**. It does not contain agents. Agents that consume BCQuality ship with [AL-Go](https://github.com/microsoft/AL-Go) and other orchestrators.

### Knowledge files

Atomic markdown files with YAML frontmatter. Each file covers one concern — one thing an agent would cite when reviewing or generating code. Knowledge files live in three layers:

- **`/microsoft/`** — Microsoft-endorsed layer.
  - `/microsoft/knowledge/` — Platform guardrails, official guidance.
  - `/microsoft/skills/` — Microsoft-endorsed action skills.
- **`/community/`** — BC community layer.
  - `/community/knowledge/` — Community patterns and shared guidance.
  - `/community/skills/` — Community-contributed action skills.

- **`/custom/`** — Partner- and customer-specific overrides. Empty by default; populated in forks.
  - `/custom/knowledge/` — Organization-specific knowledge files.
  - `/custom/skills/` — Organization-specific action skills.

All three layers are enabled by default when an agent consumes BCQuality. In the shared upstream layers, an action skill and the canonical knowledge it owns should live together: knowledge used by a Microsoft-endorsed skill belongs in `/microsoft/`, while `/community/` holds community-owned skills and their related knowledge. A split is acceptable briefly while a skill or corpus is being promoted, but it should not be the steady state. The `/custom/` layer remains the intentional exception because it overrides shared content in consumer forks.

Layer authority follows review and ownership, not the contributor's affiliation. Community contributions to a Microsoft-owned knowledge domain can therefore be accepted directly into `/microsoft/`; content can also be promoted from Community to Microsoft-endorsed once its owning skill is promoted.

### Skills

Skills define how agents consume knowledge. They come in three flavors:

- **The entry-point skill** ([`skills/entry.md`](skills/entry.md)) — the first skill an agent invokes at runtime. Given a task context (goal, available inputs, technologies, BC version, etc.), it returns a **dispatch record** naming the action skill or skills to invoke next. Routing logic lives here, not in the orchestrator.

- **Meta-skill contracts** (`/skills/`) — three stable references that define the rest of the repo:
  1. **Schema + Use** (READ, [`skills/read.md`](skills/read.md)) — how to read a knowledge file: interpret frontmatter, parse sections, understand layer precedence. Any agent or skill that reads knowledge files depends on it.
  2. **Action Skill** (DO, [`skills/do.md`](skills/do.md)) — the template every action skill follows. Defines the four-step pattern (Source → Relevance → Worklist → Action) and the structured output format that orchestrators expect.
  3. **New Knowledge** (WRITE, [`skills/write.md`](skills/write.md)) — how to author a valid knowledge file. References Schema + Use for the format specification and adds authoring rules (atomicity, section guidance).

  READ and DO are read on demand — typically when the first dispatched action skill runs. They are not prerequisites for invoking Entry. WRITE is only used when scaffolding new content.

- **Action skills** — concrete skills that follow the Action Skill template to do real work (review code, audit telemetry, etc.). Action skills live inside the layers that own them (`/microsoft/skills/`, `/community/skills/`, `/custom/skills/`). An action skill is either a **leaf** that evaluates knowledge files directly, or a **super-skill** that composes other action skills (declared via `sub-skills` in frontmatter). The canonical reference is [`microsoft/skills/review/al-code-review.md`](microsoft/skills/review/al-code-review.md) (super-skill), which composes the AL review leaf skills under [`microsoft/skills/review/`](microsoft/skills/review/) — one per knowledge domain.

### Agent bootstrapping

An orchestrator (such as AL-Go) points the agent at BCQuality's URL and provides a task context. The agent's first call is `/skills/entry.md`, which returns a dispatch record naming the action skill(s) to invoke. The agent then invokes each dispatched skill in turn, reading READ and DO on demand. No prior knowledge of BCQuality's structure is baked into the orchestrator — only the convention *"invoke `/skills/entry.md` first."*

### Standalone plugin installation

BCQuality can also be installed directly as a plugin. The plugin registers one
host-native skill,
[`al-code-review`](skills/al-code-review/SKILL.md), which adapts the caller's
request to the same Entry protocol used by orchestrators.

For GitHub Copilot CLI:

```shell
copilot plugin install microsoft/BCQuality
```

Plugin version `0.2.0` renamed the former `bcquality-al-review` skill to
`al-code-review`; explicit invocations and allowlists using the old skill name
must be updated. The name remains distinct from BC-ALAgents' public
`al-review` skill because current hosts may load plugin skill names into one
shared inventory.

The adapter is intentionally not a second review implementation:

```text
standalone host skill: skills/al-code-review/SKILL.md
  -> routing contract: skills/entry.md
    -> review coordinator: microsoft/skills/review/al-code-review.md
      -> domain review leaves
```

Only the first file follows the host's `SKILL.md` packaging format. The
remaining files are BCQuality's internal protocol and layered action skills.
Entry remains the single owner of routing and index preparation;
`al-code-review.md` remains the single owner of broad-review composition. This
separation keeps standalone installation available without duplicating those
policies in the plugin adapter.

Note that a plugin install ships the entire tree, so `BCQUALITY_ENABLED_LAYERS`
narrows discovery without removing any files. Layer selection is a filter here,
not a deny mechanism — see [the adapter](skills/al-code-review/SKILL.md) for the
difference from the pruned-clone model.

The host adapter and internal action skill intentionally share the
`al-code-review` name: they expose the same operation in two different skill
formats. Their paths make the boundary explicit. The adapter lives under
`skills/al-code-review/SKILL.md`; the internal Microsoft-layer coordinator
lives at `microsoft/skills/review/al-code-review.md`.

## Knowledge file format

Every knowledge file is a markdown file with mandatory YAML frontmatter. Files target under 100 lines (ideal under 50). If two ideas would share a file, split them.

### Frontmatter schema (v1)

```yaml
---
bc-version: [all]                       # or [26..28], or [26..] for "26 and later"
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

The current curated corpus is focused on **technical AL code review**: Agents, AppSource and compatibility, data modeling, error handling, events, interfaces, performance, privacy, Query objects, security, style, telemetry, testing, UI, upgrade, and web services. These are the domains backed by knowledge files and registered review leaves today.

Business Central functional domains (Finance, Supply Chain Management, Manufacturing, Jobs, Warehousing, Service), PowerShell, pipelines, and Power Platform remain valid future repository scope, but they are **not current coverage claims** until corresponding knowledge and action skills exist. Consumers should derive supported review scope from the live knowledge index and dispatched skills, not from roadmap breadth.

## How agents consume BCQuality

Action skills follow a four-step pattern:

1. **Source** — which knowledge folders and tags to search
2. **Relevance** — filter by frontmatter (version, technology, country, area)
3. **Worklist** — narrow from N candidates to the M that apply to the current task
4. **Action** — apply the relevant knowledge and produce structured output

Every action skill produces output in a common format that orchestrators can consume without skill-specific parsing. The format is JSON and includes an `outcome` (so a clean run, a not-applicable skill, and a partial failure are all distinguishable), `findings` (what the skill observed), structured `references` back to the knowledge files that informed each finding, per-finding `confidence`, and a `suppressed` list recording any knowledge files overridden by layer precedence. This contract is defined in the Action Skill meta-skill so that orchestrators and action skills remain independently evolvable.

BCQuality is an **additive** knowledge layer: it augments the agent's review judgement, it does not replace it. Super-skills (such as `al-code-review`) run a self-review pass alongside their sub-skills and surface concerns the agent identified on its own, marked with `from-sub-skill: "agent"` and an empty `references: []` so consumers can render them distinctly from knowledge-backed findings. See [agent-consumption.md](agent-consumption.md) and [`skills/do.md`](skills/do.md) for the full contract.

The meta-skills in `/skills/` define this pattern. Every concrete action skill follows it.

For the end-to-end flow — from orchestrator trigger through to how output reaches developers — see [agent-consumption.md](agent-consumption.md).

## Repository structure

```
├── /skills/              # Global: entry-point skill + meta-skill contracts (READ, DO, WRITE)
├── /evaluation/          # Neutral good/bad review fixtures and scoring contract
├── /.github/             # Actions and workflows
├── /microsoft/           # Microsoft-endorsed layer
│   ├── /knowledge/       # Knowledge files by domain
│   │   └── /<domain>/    # Each article: <slug>.md + optional <slug>.good.al / <slug>.bad.al
│   └── /skills/          # Microsoft-endorsed action skills
├── /community/           # BC community layer
│   ├── /knowledge/       # Knowledge files by domain
│   │   └── /<domain>/    # Article + sibling samples, same convention
│   └── /skills/          # Community action skills
├── /custom/              # Partner/customer-specific overrides (empty; populated in forks)
│   ├── /knowledge/
│   └── /skills/
```

## Versioning

BCQuality content is released on demand — roughly monthly, not on every commit. A
release is a `major.minor` value derived from git tags, cut manually via the
`Release version` workflow: pick whether to bump the minor or the major, and it
computes the next version and tags the current `main` as `v{major}.{minor}`.

- Bump the **minor** for the usual periodic content update; bump the **major**
  only for a breaking change.
- The minor is a **monotonic counter** — it only ever increments and never
  resets, even across a major bump — so it uniquely identifies a release.

## Contributing

Contributions are welcome. Before submitting a PR:

1. Read the knowledge file format above — frontmatter and sections are validated by CI.
2. Keep files atomic: one concern per file, under 100 lines.
3. Target your contribution to the layer that owns the action skill: use `/microsoft/knowledge/` for Microsoft-owned domains and `/community/knowledge/` for knowledge that accompanies a community-owned skill.
4. Adding a BC fact — or stopping the agent from flagging a false positive — is a knowledge file, not a skill edit. If a PR changes *what* a review skill flags, the change almost certainly belongs in a knowledge file. See [`skills/write.md`](skills/write.md).

CI runs validation on every PR. If your knowledge file has schema violations, missing sections, code blocks, or exceeds 100 lines, the check will fail with a clear error message.

Companion samples must be referenced by filename from their article, and every referenced sample must exist. The review evaluation corpus under [`evaluation/`](evaluation/) adds one positive and one clean control for every registered AL review leaf; see [`evaluation/README.md`](evaluation/README.md) for credential-free validation and optional fast-model scoring.

## License

[MIT](LICENSE)
