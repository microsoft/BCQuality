# How agents consume BCQuality

BCQuality is content — knowledge files and skills. It is consumed by agents that live elsewhere (AL-Go, a VS Code extension, a GitHub Agent invocation, etc.). This document explains the end-to-end flow, so that skill authors, orchestrator maintainers, and contributors share one mental model.

For the high-level framing and repo structure, start with the [README](README.md). This document is the operational view.

## The actors

- **Orchestrator** — the tool that triggers work (e.g. AL-Go on a pull request, or a VS Code extension on save). Lives *outside* BCQuality. Knows *when* to run something, not *what* to run.
- **Agent** — an LLM-driven process spawned by the orchestrator. The agent has no built-in knowledge of BC or of BCQuality's conventions. It knows how to read instructions and call tools.
- **BCQuality repo** — two kinds of content:
  - **Meta-skills** in `/skills/` — the READ · DO · WRITE contracts that teach an agent how to work with the repo.
  - **Layer content** in `/microsoft/` and `/community/` — knowledge files and action skills grouped by authority.

## The flow

```mermaid
flowchart LR
    O[Orchestrator<br/>AL-Go] -->|1 trigger| A[Agent]
    A -->|2 read /skills/| M[Meta-skills<br/>READ · DO · WRITE]
    M -->|3 pick skill| S[Action skill<br/>e.g. al-code-review]
    S -->|4 execute| P[Source → Relevance<br/>→ Worklist → Action]
    P -->|5 emit| R[Findings · References<br/>· Confidence]
    R -->|6 integrate| O
```

### 1. Orchestrator triggers
The orchestrator has a URL setting that points at BCQuality (default: `github.com/microsoft/BCQuality`) and a task to perform. It hands the task to an agent and says: *your source of truth lives at that URL; start by reading `/skills/`*.

### 2. Agent bootstraps on meta-skills
The agent has no prior knowledge of BCQuality's conventions. It reads `/skills/` first:

- **READ** (Schema + Use) — how to interpret a knowledge file: frontmatter fields, section semantics, layer precedence. Any skill that consumes knowledge depends on this.
- **DO** (Action Skill) — the template every action skill follows. Defines the four-step pattern and the structured output format.
- **WRITE** (New Knowledge) — authoring rules. Not used during consumption; used when contributors or agents scaffold new knowledge.

After this step, the agent is fluent in BCQuality without anything hardcoded in the orchestrator.

### 3. Agent selects an action skill
Action skills live inside the layers — `/microsoft/skills/` and `/community/skills/` — so their authority is carried by their location. For a PR review, the agent finds a review-type skill (for example `microsoft/skills/al-code-review.md`) and loads it.

### 4. Action skill executes the four-step pattern

Each action skill is a markdown file that specifies what to do at each step. The template is always the same:

| Step | What happens |
| --- | --- |
| **Source** | Declare which knowledge folders and tags to search. |
| **Relevance** | Filter by frontmatter — `bc-version`, `technologies`, `countries`, `application-area`. |
| **Worklist** | Narrow from N candidates to the M that apply to this specific task. |
| **Action** | Apply the relevant knowledge and produce structured output. |

Example: a performance review skill sources from `/microsoft/knowledge/performance/` and `/community/knowledge/performance/`, filters to `bc-version: 26` and `technologies: [al]`, narrows the 25 candidate files to the 8 that apply to the 15 objects changed in the PR, and then evaluates each file against the diff.

### 5. Agent emits structured output
The output contract is defined in the DO meta-skill so that every action skill — today's and next year's — produces the same shape:

- **Outcome** — `completed`, `not-applicable`, `no-knowledge`, `partial`, or `failed`. An orchestrator can distinguish a clean run from a no-op from a failure without guessing.
- **Findings** — what the skill observed (severity, message, optional location).
- **References** — structured objects (`path` plus optional commit `sha`) pointing to the knowledge files that informed each finding.
- **Confidence** — per-finding evidence strength.
- **Suppressed** — knowledge files that were discarded by layer precedence or configuration, so reviewers can see what was overridden.

The orchestrator parses this **without skill-specific logic**. This is the point of the contract: orchestrators and action skills evolve independently.

### 6. Orchestrator integrates
The orchestrator turns findings into PR comments, build gates, or IDE diagnostics, and links the references back to the knowledge files so the PR author — human or agent — can read the guidance.

## Why this architecture

- **Meta-skills are the only hardcoded thing.** Orchestrators ship with knowledge of `/skills/` and nothing else. New action skills and new knowledge files are picked up automatically.
- **Layers decide authority, not code.** The agent sees `/microsoft/` and `/community/` together; if two files conflict, the precedence rule defined in READ resolves it. A partner fork can disable `/community/` — that's a config choice, not a code change.
- **Knowledge and skills evolve independently.** A new knowledge file requires no skill changes — existing skills pick it up via frontmatter filters. A new skill requires no knowledge changes — it sources from what's already there.

## The mental model, in one sentence

The orchestrator knows **when** to run; the meta-skills teach the agent **how** to behave; the action skills define **what** to do; the knowledge files are **what** the agent knows.
