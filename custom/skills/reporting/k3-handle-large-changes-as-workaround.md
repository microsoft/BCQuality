---
name: K3 Handle Large Changes as Workaround
description: "Recover reliable file-level analysis when Git diff or blame output is truncated by the integration. Use during delivery-report discovery or source analysis when output is incomplete."
type: skill
scope: workspace
---

# K3 Handle Large Changes as Workaround

Use this when a Git integration returns only a truncated preview of a large diff or blame result. In some environments the complete output is stored as one long JSON line and the file reader truncates that line; requesting another line range will not reveal the rest. Some Git integrations also accept only a revision range, so adding flags or path arguments can fail.

## Procedure

1. Preserve the truncated output as partial evidence only; do not infer missing hunks from it.
2. Get the relevant ordered file list from the scope-appropriate status or branch comparison described in [K3 Discover Branch AL Changes](./k3-discover-branch-al-changes.md).
3. Read the full current contents of each changed source file.
4. When available, retrieve the base-branch version of each modified file and compare the two complete versions. If repository access is unavailable, state that the exact hunk could not be confirmed.
5. Base summaries only on verified current contents and confirmed differences. Flag remaining uncertainty in the report.

## Output

Return the files and changes that could be verified, plus a concise list of unconfirmed hunks. Never claim that a partial preview is a complete diff.
