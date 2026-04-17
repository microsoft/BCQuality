# BCQuality meta-skills

This folder contains the three global meta-skills — the contracts every consumer of BCQuality depends on. They are small, stable, and layer-agnostic.

If you are an agent being pointed at BCQuality for the first time, read these files in order:

| # | File | Role | Who reads it |
|---|---|---|---|
| 1 | [`read.md`](read.md) | **READ** — Schema + Use. How to read a knowledge file: frontmatter fields, section semantics, matching rules, layer precedence, conflict resolution. | Any agent or action skill that consumes knowledge files. |
| 2 | [`do.md`](do.md) | **DO** — Action Skill contract. The Source → Relevance → Worklist → Action template and the structured output every action skill produces. Includes super-skill composition. | Any agent invoking an action skill; every action-skill author. |
| 3 | [`write.md`](write.md) | **WRITE** — New Knowledge. Authoring rules for knowledge files. Defers to `read.md` for the schema. | Contributors (human or agent) who are adding or editing knowledge files. Not used during consumption. |

After reading `read.md` and `do.md`, an agent has everything it needs to pick an action skill from `/microsoft/skills/` or `/community/skills/` and execute it. `write.md` is only needed when scaffolding new content.

These contracts are stable. Changes require a PR approved by both maintainers.

For the end-to-end flow — from orchestrator trigger through to findings integration — see [`../agent-consumption.md`](../agent-consumption.md). For the high-level project framing, see [`../README.md`](../README.md).
