---
name: al-knowledge
description: Answer Business Central development questions from BCQuality's installed knowledge articles, with exact citations and no code review. Use for design, specification, or a focused knowledge question.
---

# AL knowledge consultation

This is the public skill entry point: the file the host agent reads to start
the skill. It tells the agent how to prepare the question and follow
BCQuality's routing instructions. The same agent can execute all steps
inline; no separate program or agent is required.

This file is distinct from `skills/entry.md`, which owns routing. Article
selection, precedence, and output policy belong to Entry, READ, DO, and the
dispatched internal action skill.

## Execute

1. Resolve `PLUGIN_ROOT` from the installed plugin's `plugin.json`; this file is
   `PLUGIN_ROOT/skills/al-knowledge/SKILL.md`. Never assume the user's app root
   is the plugin root.
2. Build Entry's `task-context`. Copy the caller's question verbatim into `goal`.
   Set `inputs-available: [knowledge-query]` and bind `knowledge-query` to that
   exact question. Pass `technologies`, `bc-version`, `countries`, and
   `application-area` only when provided or reliably determined. Pass the
   optional `BCQUALITY_ENABLED_LAYERS` and `BCQUALITY_DISABLED_SKILLS` settings
   using the same parsing rules as `al-code-review`.
3. Read and execute `PLUGIN_ROOT/skills/entry.md`, including Preparation,
   resolving all paths against `PLUGIN_ROOT`. If `pwsh` or index generation is
   unavailable, use the documented path-based discovery fallback.
4. Execute only the dispatched action skills with their exact input subsets.
   Read `PLUGIN_ROOT/skills/read.md` and `PLUGIN_ROOT/skills/do.md` on demand.
   Do not call `al-code-review` for this knowledge question, synthesize a
   dispatch, or turn an explanation into a finding.
5. Validate the action skill's `knowledge-response` under DO before accepting
   it: check the schema, exact bound question, and current-run full reads of
   every cited path. The consumer can use
   `PLUGIN_ROOT/tools/validate_knowledge_response.py` with its own question
   and read evidence. Preserve the raw result when validation fails; record
   that failure separately instead of repairing or accepting the answer.
   Inline checks by the answering agent are self-attestation, not independent
   verification. Independent checks require a trusted consumer read collector.
   Return a valid response unchanged, or Entry's `no-match` / `failed`
   dispatch record unchanged.

Where the host has no tool to invoke a skill and skills are instruction files the
agent reads (for example VS Code Copilot), invoking this skill means executing
steps 1–5 inline in the caller's own context. The `knowledge-response` the
dispatched action skill produces there is the response to return: producing it
that way is the protocol, not a fabrication. Lacking an invocation tool is never
a reason to skip this skill or to answer without its response.
