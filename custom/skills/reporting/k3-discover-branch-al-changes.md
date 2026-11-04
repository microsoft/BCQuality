---
name: K3 Discover Branch AL Changes
description: "Identify the repository, feature branch, base branch, pull request, and exact files in a delivery-report scope. Use when preparing a branch, PR, or worktree delivery report."
type: skill
scope: workspace
---

# K3 Discover Branch AL Changes

Determine exactly which changes the delivery report covers. Do not infer the change set from an old report or branch name alone.

## Procedure

1. Identify the repository root, current branch, upstream, and request scope. Distinguish a committed feature-branch report from a report of current uncommitted changes.
2. Record `git status --short --branch` in the relevant repository. This captures staged, unstaged, and untracked worktree changes.
3. For a committed feature branch, identify the base branch and compare the feature branch with it, for example with `git diff --name-status <base>...HEAD`. Keep worktree changes as a separate list; do not let an unrelated report-file deletion hide the committed feature files.
4. Determine the authoritative changed-file list and preserve the order from the selected status or diff output. Mark each file added, modified, or deleted. If the base branch or scope is unclear, stop and ask rather than guessing.
5. Confirm the repository owner/name and any delivering pull request from repository metadata or GitHub. Use `none yet` if no PR can be confirmed.
6. Exclude `AppSourceCop.json`, `app.json`, and `docs/internal/delivery reports/delivery-report-feature-<ID>.md` from functional file coverage and change metrics. Do not treat exclusions as open items.

## Output

Return the feature ID, branch, base branch, repository owner/name, confirmed PR link(s) or `none yet`, selected scope, ordered file list with change status, and any discovery limitations. This output feeds [K3 Analyse AL Changes](./k3-analyse-al-changes.md).
