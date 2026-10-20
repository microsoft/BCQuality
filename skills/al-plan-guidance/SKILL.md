---
name: al-plan-guidance
description: Preview. Enrich an existing Business Central AL development plan with applicable BCQuality guidance before implementation, without changing the plan or repository. Use when the caller supplies a plan file or plan text for an AL change.
---

# AL plan guidance (preview)

This is BCQuality's host-native adapter for applying knowledge to an existing
AL development plan. It is a preview: the underlying contract may change based
on pilot feedback. It is not a BCQuality action skill and contains no routing
or knowledge-selection policy. Its only responsibility is to translate the
caller's request into an Entry task context and execute the resulting dispatch.

The adapter is read-only. It never creates or rewrites the plan, edits source,
writes generated files into the caller's repository, runs tests, or implements
the change.

## Execute

1. Resolve `PLUGIN_ROOT` to the directory containing this plugin's root
   `plugin.json`. This file is
   `PLUGIN_ROOT/skills/al-plan-guidance/SKILL.md`; when the host does not
   expose the plugin root, resolve it two levels above this file.
2. Identify the caller's existing plan: a plan file path, plan text in the
   request, or a plan the caller explicitly identifies in the conversation. If
   no plan is available, ask the caller for one. Do not generate a plan; this
   skill enriches an existing one.
3. Build the `task-context` required by `PLUGIN_ROOT/skills/entry.md`:
   - Copy the caller's actual request verbatim into `goal`.
   - Set `inputs-available` to `development-plan`, plus `repository` when the
     caller's AL repository or app folder is readable. Pass the complete plan
     content as `development-plan` and the repository path as `repository`;
     for a request in the caller's working directory, use that directory.
   - Set `technologies: [al]`.
   - Pass `bc-version`, `countries`, and `application-area` only when supplied
     or reliably determined from the plan or repository.
   - If `BCQUALITY_ENABLED_LAYERS` is set, split its comma-separated value and
     pass the trimmed, non-empty entries as `enabled-layers`; otherwise omit the
     field and let Entry apply its default.
   - If `BCQUALITY_DISABLED_SKILLS` is set, split its comma-separated value and
     pass the trimmed, non-empty entries as `disabled-skills`; otherwise omit
     the field.
4. Read and execute `PLUGIN_ROOT/skills/entry.md` exactly as written, including
   its Preparation step. Entry is authoritative for index freshness, routing,
   defaults, and failure behavior; this adapter must not duplicate or weaken
   those rules. Resolve every repo-relative path Entry names against
   `PLUGIN_ROOT`, not the caller's working directory. Run Preparation's index
   build as `pwsh PLUGIN_ROOT/tools/Build-KnowledgeIndex.ps1`. If `PLUGIN_ROOT`
   is inside the caller's repository, pass `-IndexPath` to a location outside
   that repository and supply the resulting index path to the dispatched skill.
   If `pwsh` is unavailable or the build fails, continue with READ's
   path-based discovery; a failed build is not empty knowledge.
5. Follow Entry's **How the agent uses the dispatch** instructions. Invoke only
   the returned action skills, pass each dispatch entry's exact input subset,
   and read `PLUGIN_ROOT/skills/read.md` and `PLUGIN_ROOT/skills/do.md` on
   demand.
6. Return each dispatched development guidance report unchanged. If Entry
   returns `no-match` or `failed`, return its dispatch record unchanged.

The internal `microsoft/skills/development/al-development-plan.md` action skill
selects and converts the applicable knowledge. This adapter never selects
articles itself.

## Using the result

Give the guidance report to the agent implementing the plan, together with the
plan itself. After implementation, review the completed change with
`al-code-review`; the guidance report is input to the work, not proof that the
result is correct.

## Layer selection is not a deny mechanism

A plugin install ships the whole BCQuality tree, so `enabled-layers` here can
only narrow *discovery*: the files of a layer left out of the list still exist
on disk. Treat `BCQUALITY_ENABLED_LAYERS` as a selection filter, never as a
security boundary. A host that needs a genuine deny mechanism must prune the
installed tree itself.
