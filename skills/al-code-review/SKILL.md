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
   those rules.
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
