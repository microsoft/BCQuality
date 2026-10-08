# BCQuality global skills

This folder contains BCQuality's layer-independent protocol files and the
public skill entry points used by standalone plugin installations.

The protocol files have two kinds:

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

## Public skill entry points

| Path | Role |
|---|---|
| [`al-code-review/SKILL.md`](al-code-review/SKILL.md) | Starts a code review through the standard host `SKILL.md` format. |
| [`al-knowledge/SKILL.md`](al-knowledge/SKILL.md) | Starts a cited knowledge consultation for design, specification or a focused development question. |

These files tell the host agent how to start the skill: resolve BCQuality's
root, prepare the caller's request, and follow Entry's dispatch. They do not
own routing, article selection, index preparation or output policy. They are
not action skills and are not candidates for Entry. Their behavior follows
`entry.md`, `read.md`, `do.md`, and the selected internal action skill.

The same agent can execute the instructions inline when the host has no
separate skill-invocation tool. A file read alone does not complete execution.

This gives the two skill formats distinct roles:

- `skills/al-code-review/SKILL.md` is the public host integration surface for a
  standalone plugin installation.
- `microsoft/skills/review/al-code-review.md` is BCQuality's internal
  Microsoft-layer super-skill for coordinating a broad AL review.

The host adapter and internal coordinator deliberately share the
`al-code-review` name because they represent the same user-facing operation in
their respective formats. Their locations distinguish their roles. The
reference from the adapter to Entry, and from a dispatched super-skill to its
leaf skills, is intentional progressive disclosure. It avoids registering
every internal BCQuality protocol file as an ambient host skill while allowing
each review domain to run in an isolated context.

These contracts are stable. Changes require a PR approved by both maintainers.

For the end-to-end flow — from orchestrator trigger through to findings integration — see [How agents consume BCQuality](../docs/agent-consumption.md). For the high-level project framing, see [`../README.md`](../README.md).
