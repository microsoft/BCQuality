---
name: K3 Analyse AL Changes
description: "Verify AL feature-branch changes object by object and identify behavior, affected users, tests, and open items. Use when analyzing AL files for a delivery report."
type: skill
scope: workspace
---

# K3 Analyse AL Changes

Analyze every functional file in the discovered change set. Ground all statements in the current source, a base-branch comparison, or verified repository metadata.

## Procedure

1. Follow the ordered file list from [K3 Discover Branch AL Changes](./k3-discover-branch-al-changes.md). Do not silently omit files. Excluded manifest, analyzer-baseline, and report files stay excluded.
2. For each added file, read its full contents and verify the AL object type, ID, name, purpose, and interactions.
3. For each modified file, read the full relevant source and inspect its diff against the chosen base. Trace changed logic to the nearest direct implementation and relevant calls/events. For deleted files, inspect the base-branch version when available.
4. Record the verified change as a concise file-level summary, not a line-by-line diff. Describe user-visible behavior, conditions, confirmation/permission behavior, compatibility effects, and prerequisites only when confirmed.
5. Derive concrete functional checks from the logic read. Include important positive, negative, boundary, and compatibility paths; describe them as proposed checks, not tests already run.
6. Record uncertain hunks, missing repository data, runtime assumptions, and latent inconsistencies as clearly flagged open items. Do not turn an inference into a factual claim.
7. Do not mention authors, committers, reviewers, or mergers in the report. PR links and verified dates may be included without merge status or merge dates.

## Large Diffs

When a Git integration truncates a diff, follow [K3 Handle Large Changes as Workaround](./k3-handle-large-changes-as-workaround.md). Never treat a truncated preview as a complete diff.

## Output

Return one verified record per file, in the supplied order, with filename, relative path, AL object identity, change status, and a concise global-change paragraph. Also return observed functionality, test checklist candidates, deployment considerations, and flagged open items. Pass these facts to [K3 Format Delivery Report](./k3-format-delivery-report.md).
