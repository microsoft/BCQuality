---
name: al-development
description: Implement Business Central AL features, bug fixes, refactors, upgrades, and maintenance changes using BCQuality's curated platform knowledge.
---

# AL development

This is BCQuality's host-native adapter for standalone plugin installations. It translates a coding request into Entry's task context; the internal action skill owns classification, investigation, design, implementation, validation, and review policy.

When the target repository exposes a more specific local workflow for the request, such as an end-to-end bug-fix skill with its own environment and delivery gates, prefer that repository workflow unless the caller explicitly asks to use BCQuality's generic development skill.

## Execute

1. Resolve `PLUGIN_ROOT` to the directory containing this plugin's root `plugin.json`. This file is `PLUGIN_ROOT/skills/al-development/SKILL.md`; when the host does not expose the plugin root, resolve it two levels above this file.
2. Build the `task-context` required by `PLUGIN_ROOT/skills/entry.md`:
   - Copy the caller's request verbatim into `goal`.
   - Set `inputs-available: [development-request, repository]`.
   - Set `technologies: [al]` when the repository is an AL project.
   - Pass `bc-version`, `countries`, and `application-area` only when supplied or reliably determined.
   - Apply `BCQUALITY_ENABLED_LAYERS` and `BCQUALITY_DISABLED_SKILLS` exactly as the `al-code-review` adapter does.
3. Read and execute `PLUGIN_ROOT/skills/entry.md`, including Preparation. Resolve every path it names against `PLUGIN_ROOT`, not the user's repository. If knowledge-index generation is unavailable, use READ's path-based fallback.
4. Follow Entry's dispatch exactly. The normal result is `microsoft/skills/development/al-development.md`; do not select it directly or duplicate its behavior in this adapter.
5. Normalize the caller's input as `development-request`:
   - Plain text becomes `{ kind: auto, description: <verbatim text> }`.
   - Preserve an explicit `kind`, supplied plan, and `acceptance-criteria`.
   - A plan-only input becomes `{ kind: auto, description: "Implement the supplied development plan.", plan: <verbatim plan> }`.
   Pass the writable current workspace as `repository`, execute the dispatched skill, and return its `implementation-report` unchanged.

The adapter never edits BCQuality itself unless BCQuality is the caller's target repository. The target of implementation is the repository supplied by the caller.
