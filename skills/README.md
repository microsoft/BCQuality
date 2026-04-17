# BCQuality global skills

This folder contains the skills that are not owned by any single layer. There are two kinds:

- **The entry-point skill** — the first skill an agent invokes at runtime.
- **The three meta-skill contracts** — stable references that define what the rest of BCQuality means.

## The entry-point skill

| File | Role |
|---|---|
| [`entry.md`](entry.md) | **ENTRY** — Given a task context, returns a dispatch record naming the action skill(s) to invoke. The agent's first call when pointed at BCQuality. |

Routing logic lives in Entry, not in the orchestrator. An agent that knows only "invoke `/skills/entry.md` first" has enough to drive the rest of the repo.

## The meta-skill contracts

| # | File | Role | Who reads it |
|---|---|---|---|
| 1 | [`read.md`](read.md) | **READ** — Schema + Use. How to read a knowledge file: frontmatter fields, section semantics, matching rules, layer precedence, conflict resolution. | Any agent or action skill that consumes knowledge files. |
| 2 | [`do.md`](do.md) | **DO** — Action Skill contract. The Source → Relevance → Worklist → Action template and the structured output every action skill produces. Includes super-skill composition. | Any agent invoking an action skill; every action-skill author. |
| 3 | [`write.md`](write.md) | **WRITE** — New Knowledge. Authoring rules for knowledge files. Defers to `read.md` for the schema. | Contributors (human or agent) adding or editing knowledge files. Not used during consumption. |

READ and DO are read on demand — typically by the first action skill the agent executes after dispatch. They are not prerequisites for invoking Entry. WRITE is only used when scaffolding new content.

These contracts are stable. Changes require a PR approved by both maintainers.

For the end-to-end flow — from orchestrator trigger through to findings integration — see [`../agent-consumption.md`](../agent-consumption.md). For the high-level project framing, see [`../README.md`](../README.md).
