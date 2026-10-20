# BCQuality global skills

This folder contains BCQuality's layer-independent protocol files and the
host-native adapters used by standalone plugin installations.

The protocol files have two kinds:

- **The entry-point skill** — BCQuality's router: the first skill an agent invokes at runtime.
- **The three meta-skill contracts** — stable references that define what the rest of BCQuality means.

## The entry-point skill

| File | Role |
|---|---|
| [`entry.md`](entry.md) | **ENTRY** — BCQuality's router. Given a task context, returns a dispatch record naming the action skill(s) to invoke. The agent's first call when pointed at BCQuality. |

Routing logic lives in Entry, not in the orchestrator. An agent that knows only "invoke `/skills/entry.md` first" has enough to drive the rest of the repo. Users of the plugin do not call Entry themselves: each host adapter below binds one capability and calls Entry on the user's behalf.

## The meta-skill contracts

| # | File | Role | Who reads it |
|---|---|---|---|
| 1 | [`read.md`](read.md) | **READ** — Schema + Use. How to read a knowledge file: frontmatter fields, section semantics, matching rules, layer precedence, conflict resolution. | Any agent or action skill that consumes knowledge files. |
| 2 | [`do.md`](do.md) | **DO** — Action Skill contract. The Source → Relevance → Worklist → Action template and the structured output every action skill produces. Includes super-skill composition. | Any agent invoking an action skill; every action-skill author. |
| 3 | [`write.md`](write.md) | **WRITE** — New Knowledge. Authoring rules for knowledge files. Defers to `read.md` for the schema. | Contributors (human or agent) adding or editing knowledge files. Not used during consumption. |

READ and DO are read on demand — typically by the first action skill the agent executes after dispatch. They are not prerequisites for invoking Entry. WRITE is only used when scaffolding new content.

## Standalone plugin adapters

| Path | Capability |
|---|---|
| [`al-code-review/SKILL.md`](al-code-review/SKILL.md) | Review AL code: an app folder, files, or changes. |
| [`al-plan-guidance/SKILL.md`](al-plan-guidance/SKILL.md) | Preview. Enrich an existing AL development plan with applicable guidance, read-only. |

Each adapter is deliberately thin. It translates the caller's request into an
Entry task context, then follows Entry's dispatch without owning routing,
review, guidance, index, or output policy. Adapters are not action skills, are
not considered by Entry, and should not accumulate behavior already defined by
`entry.md`, `read.md`, `do.md`, or a layered action skill.

Each capability therefore follows one path, with no second implementation in
its adapter:

```text
review:         skills/al-code-review/SKILL.md
                  -> router: skills/entry.md
                    -> review coordinator: microsoft/skills/review/al-code-review.md
                      -> domain review leaves

plan guidance:  skills/al-plan-guidance/SKILL.md
                  -> router: skills/entry.md
                    -> microsoft/skills/development/al-development-plan.md
```

This gives the two skill formats distinct roles:

- `skills/<capability>/SKILL.md` files are the public host integration surface
  for a standalone plugin installation.
- Action skills under `<layer>/skills/` are BCQuality's internal units of work,
  such as the Microsoft-layer `al-code-review` super-skill that coordinates a
  broad AL review.

The host adapter and internal coordinator deliberately share the
`al-code-review` name because they represent the same user-facing operation in
their respective formats. Their locations distinguish their roles. The
reference from the adapter to Entry, and from a dispatched super-skill to its
leaf skills, is intentional progressive disclosure. It avoids registering
every internal BCQuality protocol file as an ambient host skill while allowing
each review domain to run in an isolated context.

These contracts are stable. Changes require a PR approved by both maintainers.

For the end-to-end flow — from orchestrator trigger through to findings integration — see [How agents consume BCQuality](../docs/agent-consumption.md). For the high-level project framing, see [`../README.md`](../README.md).
