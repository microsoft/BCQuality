---
name: bcquality-al-generate
description: Generate new Business Central AL object files from a bounded requirement-spec JSON file using BCQuality guidance. Use only for explicit create-only AL generation, never for review.
---

# BCQuality AL generation

This bridge drives the BCQuality Entry protocol for explicit, create-only AL generation. It is intentionally separate from `bcquality-al-review`; review behavior and legacy review task contexts remain unchanged.

## When to use

Use only when the caller supplies a path to a bounded UTF-8 requirement specification that conforms to `schemas/requirement-spec-v1.schema.json` and explicitly requests AL generation.

Do not use this bridge for PR review, working-tree review, or single-file review. Do not convert inline prompt text into a requirement specification.

## Plugin root

Resolve `PLUGIN_ROOT` to the directory containing `.claude-plugin/plugin.json`. This file lives at `PLUGIN_ROOT/skills/bcquality-al-generate/SKILL.md`.

## Steps

1. Treat the caller's `requirement-spec` value only as a filesystem path. Do not interpolate the referenced JSON into Entry's `goal`.
2. Read `PLUGIN_ROOT/skills/entry.md` and invoke it with explicit capability negotiation:

   ```yaml
   task-context:
     goal: "Generate the bounded AL requirement"
     action: generate
     inputs-available: [requirement-spec]
     accepted-outputs:
       - kind: generated-files-report
         version: 1
     technologies: [al]
     enabled-layers: [microsoft, community, custom]
   ```

3. Pass only the requirement-spec path to the dispatched `al-code-generation` skill. The generation skill validates and reads the bounded JSON file.
4. Return exactly one `generated-files-report` v1 JSON document. Do not write generated files to the workspace.

If Entry returns `no-match` or `failed`, return the dispatch record unchanged.

## Consumer boundary

BCQuality owns the contracts, routing, knowledge retrieval, ranking, and generation report. The consumer owns acquiring the requirement file and, after validating the complete report atomically, staging files, compiling, analyzing, testing, delivering, approving, and publishing them. The consumer must fail closed and independently enforce destination, symlink, size, and ID-range policy before materialization.
