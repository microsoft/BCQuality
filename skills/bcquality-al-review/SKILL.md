---
name: bcquality-al-review
description: Review Business Central AL code changes using the BCQuality knowledge base. Use when reviewing an AL pull request, a working-tree diff, or a single AL file, and you want findings backed by BCQuality's curated, BC-specific quality rules.
---

# BCQuality AL review

This skill drives the BCQuality **Entry protocol** over the knowledge base that ships
inside this plugin. It is the plugin entry point for consumers (orchestrators, CLIs)
that do not already know BCQuality's internal conventions — the only convention they
need is "invoke this skill for an AL review."

BCQuality itself is orchestrator-agnostic content: knowledge files plus routing and
action skills. This bridge is the thin consumer glue that lets a plugin host run that
content without hardcoding BCQuality's layout.

## When to use

- Reviewing an AL pull request or an uncommitted working-tree diff.
- Reviewing a single AL file.
- Any task whose goal is "review Business Central / AL code for quality issues."

Do **not** use this skill to *generate* AL code — it only reviews.

## Plugin root

Resolve `PLUGIN_ROOT` to the directory that contains this plugin's
`.claude-plugin/plugin.json`. This skill lives at
`PLUGIN_ROOT/skills/bcquality-al-review/SKILL.md`, so `PLUGIN_ROOT` is two levels up
from this file. All paths below are relative to `PLUGIN_ROOT`. If the host exposes a
plugin-root environment variable, prefer it.

## Steps

1. **Refresh the knowledge index (best effort).** If `pwsh` is available, run
   `pwsh PLUGIN_ROOT/tools/Build-KnowledgeIndex.ps1` from `PLUGIN_ROOT` to (re)generate
   `PLUGIN_ROOT/knowledge-index.json` over the installed tree. This is a discovery
   accelerator only — if `pwsh` is missing or the build fails, continue; the review
   skills fall back to path-based discovery.

2. **Run Entry.** Read `PLUGIN_ROOT/skills/entry.md` and execute it against a
   task context describing the review:

   ```yaml
   task-context:
     goal: "Review the AL changes for quality issues"
     inputs-available: [pr-diff]        # or [file-path] for single-file review
     technologies: [al]
     enabled-layers: [microsoft, community, custom]
   ```

   Fill `bc-version`, `countries`, and `application-area` only when the caller
   supplies them; omit them otherwise (an omitted dimension is unconstrained).

3. **Follow the dispatch record.** Entry returns a dispatch record naming the action
   skill(s) to invoke — for a PR review this is normally
   `microsoft/skills/review/al-code-review.md`. For each dispatched skill, read the
   file and execute its Source → Relevance → Worklist → Action steps, reading
   `PLUGIN_ROOT/skills/read.md` and `PLUGIN_ROOT/skills/do.md` on demand.

4. **Emit findings.** Produce the rolled-up findings report in the DO output contract
   (`outcome`, `findings`, `references`, `confidence`, `suppressed`). Do not invent a
   different shape; downstream consumers parse the DO contract without skill-specific
   logic.

If Entry returns `no-match` or `failed`, return the dispatch record unchanged so the
caller can log the reason.

## Notes

- This skill adds nothing to BCQuality's knowledge or routing logic; it only bootstraps
  the existing Entry protocol from a plugin host. Knowledge and skill changes belong in
  the layers under `PLUGIN_ROOT/microsoft/`, `PLUGIN_ROOT/community/`, and
  `PLUGIN_ROOT/custom/`, not here.
