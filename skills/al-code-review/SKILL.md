---
name: al-code-review
description: Review Business Central AL code changes using BCQuality's curated rules. Use for an AL pull request, working-tree diff, branch, or individual AL file when BCQuality is installed as a standalone plugin.
---

# AL code review

This is BCQuality's host-native adapter for standalone plugin installations. It
is not a BCQuality action skill and contains no review or routing policy. Its
only responsibility is to translate the caller's request into an Entry task
context and execute the resulting dispatch.

## Execute

1. Resolve `PLUGIN_ROOT` to the directory containing this plugin's root
   `plugin.json`. This file is
   `PLUGIN_ROOT/skills/al-code-review/SKILL.md`; when the host does not expose
   the plugin root, resolve it two levels above this file.
2. Build the `task-context` required by
   `PLUGIN_ROOT/skills/entry.md`:
   - Copy the caller's actual request verbatim into `goal`; do not replace a
     focused request such as "review performance" with a generic full-review
     goal.
   - Set `inputs-available` to the inputs actually available to the review,
     normally `pr-diff` for changes or `file-path` for one file.
   - Set `technologies: [al]` when the input is known to be AL.
   - Pass `bc-version`, `countries`, and `application-area` only when supplied
     or reliably determined.
   - If `BCQUALITY_ENABLED_LAYERS` is set, split its comma-separated value and
     pass the trimmed, non-empty entries as `enabled-layers`; otherwise omit the
     field and let Entry apply its default.
   - If `BCQUALITY_DISABLED_SKILLS` is set, split its comma-separated value and
     pass the trimmed, non-empty entries as `disabled-skills`; otherwise omit
     the field.
3. Read and execute `PLUGIN_ROOT/skills/entry.md` exactly as written, including
   its Preparation step. Entry is authoritative for index freshness, routing,
   defaults, and failure behavior; this adapter must not duplicate or weaken
   those rules. Entry is written for a checkout whose root is the current
   directory, so resolve every repo-relative path it names against
   `PLUGIN_ROOT` rather than the caller's working directory, which is the
   user's own project. In particular, run Preparation's index build as
   `pwsh PLUGIN_ROOT/tools/Build-KnowledgeIndex.ps1`: the generator resolves
   its own root and writes `PLUGIN_ROOT/knowledge-index.json`, which is not
   shipped and is therefore absent on a fresh install. If `pwsh` is
   unavailable or the build fails, continue — READ falls back to path-based
   discovery — but do not treat a failed build as a failed review.
4. Follow Entry's **How the agent uses the dispatch** instructions. Invoke only
   the returned action skills, pass each dispatch entry's exact input subset,
   and read `PLUGIN_ROOT/skills/read.md` and `PLUGIN_ROOT/skills/do.md` on
   demand. When a dispatched super-skill requests isolated leaf execution and
   the host supports child contexts, use them.
5. Return each dispatched action skill's findings report unchanged. If Entry
   returns `no-match` or `failed`, return its dispatch record unchanged.

The internal `microsoft/skills/review/al-code-review.md` action skill remains
the canonical coordinator for a broad AL review. Entry decides whether that
super-skill or a narrower domain skill applies; this host adapter never chooses
between them.

## Layer selection is not a deny mechanism

A plugin install ships the whole BCQuality tree, so `enabled-layers` here can
only narrow *discovery*: the files of a layer left out of the list still exist
on disk. This differs from the clone model Entry's Preparation step describes,
where a consumer prunes its checkout to policy before the agent runs and the
index is rebuilt over the pruned tree. Treat `BCQUALITY_ENABLED_LAYERS` as a
selection filter, never as a security boundary. A host that needs a genuine
deny mechanism must prune the installed tree itself.

