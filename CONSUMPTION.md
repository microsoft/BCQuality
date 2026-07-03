# How CURABIS consumes BCQuality today

[agent-consumption.md](agent-consumption.md) describes the upstream
Microsoft/BCQuality architecture: an orchestrator invokes `/skills/entry.md`,
Entry dispatches layer action skills, each skill runs Source → Relevance →
Worklist → Action and emits DO-shaped findings. That document is the
*architecture*. This document is the *actual state* — which consumption paths
are live, and which are dormant upstream inheritance.

## The two-repo architecture

- **`Curabis/BCQuality`** (PUBLIC, fork of microsoft/BCQuality): the intake.
  Carries only upstream content — `microsoft/`, `community/`, `skills/`,
  `tools/`. Synced from Microsoft via GitHub's *Sync fork*. It is also the
  contribution path: community-layer improvements go upstream through it.
  It NEVER contains the custom layer.
- **`Curabis/QualityHub`** (PRIVATE, this repo): the product. Custom layer,
  agents, setup machinery, release channel, governance — everything below.
  Because QualityHub shares git ancestry with microsoft/BCQuality, upstream
  updates arrive as a clean merge.

**"Opdater QualityHub fra BCQuality":** fetch the `bcquality` remote → merge
`bcquality/main` on a branch → PR (CI validates the merged corpus, catching
upstream schema drift at the gate) → Michael merges → promote. Never merge
upstream directly into `stable`.

## Active: the CURABIS Standard session model

The only consumption path in production. Deployed and updated by
[custom/setup/curabis-standard.agent.md](custom/setup/curabis-standard.agent.md):

- **Knowledge** is mirrored to each developer's machine at
  `~/.claude/bcquality-knowledge/` (all three layers + `INDEX.md`) by
  `custom/setup/sync-bcquality-knowledge.ps1`. The mirror is machine-local,
  never committed to a project repo — see rule
  `custom/knowledge/architecture/bcquality-knowledge-must-mirror-to-machine-not-repo.md`.
- **Sessions** (Claude Code, and Copilot via each repo's
  `copilot-instructions.md`) read the project's `.github/.agents/bcquality.agent.md`
  plus the machine mirror at session start: `custom/` in full, `community/` and
  `microsoft/` on relevance via `INDEX.md`.
- **Agents** (`.github/.agents/*.agent.md`) are per-repo copies fetched from
  `custom/agents/` and `custom/setup/templates/`, reconciled by Mode B.

## Dormant: the Entry/orchestrator flow

Inherited from upstream and kept in sync with it, but **no orchestrator invokes
it today** — no CURABIS AL-Go workflow references `entry.md`. Reserved for a
future CI/PR-review integration:

- `/skills/entry.md` + READ · DO · WRITE contracts
- Layer action skills (`microsoft/skills/review/*` — 12 review skills)
- `tools/Build-KnowledgeIndex.ps1` + `knowledge-index.json` generation
- `.github/bcquality.config.yaml` in project repos: the consumer pruning
  policy for this flow (repo, ref, enabled-layers, disabled-skills). It is
  currently consumed by nothing. Keep it — but do not mistake it for active
  configuration of the session model.

## Access model: PRIVATE repo, git-based consumption

BCQuality is a **private** repository. All consumption is git-based through
the **channel clone** at `%USERPROFILE%\.claude\QualityHub`, pinned to the
`stable` branch. Authentication is Git Credential Manager — the developer's
existing GitHub login; the first git contact opens a browser login, and that
is the entire token story. `raw.githubusercontent.com` and unauthenticated
GitHub-API calls are dead and must not appear in any consumer.

## Machine onboarding (new developer)

Two lines (idempotent — safe to re-run; the clone prompts the GCM login):

    git clone --branch stable --single-branch https://github.com/Curabis/QualityHub.git "$env:USERPROFILE\.claude\QualityHub"
    powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\QualityHub\custom\setup\machine\Install-CurabisMachine.ps1"

It installs the global CLAUDE.md (identity substituted from git config),
bc-mcp-bridge.js, the bc-mcp config template (the developer inserts their
personal client secret), the knowledge sync script, and syncs the machine
mirror from the clone. Per repo afterwards: "Opdater CURABIS Standard fra
BCQuality" — it deploys `.vscode/find-altool.ps1` and the AL MCP wiring
itself. The AL Language extension from the Marketplace is the only
per-machine prerequisite for AL MCP.

**Auto-trigger:** the lines above rarely need to be run by hand. Every
project CLAUDE.md (setup v15+) carries a machine self-heal: any Claude Code
session in any configured CURABIS repo detects an un-onboarded machine
(missing `~/.claude/CLAUDE.md` or bridge) and runs the onboarding itself —
cloning a CURABIS repo IS the onboarding. Only the personal client secret
and the VS Code AL extension remain manual by design.

## Release channel: `stable`

Merging to `main` is **not** a deployment. All consumers — the machine
CLAUDE.md auto-update, `sync-bcquality-knowledge.ps1`, the setup agent's
fetch URLs, and the agent templates' knowledge references — read from the
**`stable`** branch, never from `main`. `main` is where PRs land and CI runs;
`stable` is what every developer machine actually executes.

Deploying is a deliberate act (Michael only). Three equivalent ways, safest
first:

**The button (works from any device):** GitHub → Actions → *Promote to
stable* → Run workflow. Refuses to run if the channel has diverged; writes a
summary of the promoted commits.

**The one-liner (from any up-to-date clone, touches no working tree):**

    git fetch origin
    git push origin origin/main:stable

Git itself refuses a non-fast-forward push — if it is rejected, someone has
committed directly to stable: that is a finding, never a reason to force.

**The explicit form (for understanding what a promote IS):**

    git checkout stable
    git merge --ff-only main
    git push origin stable
    git checkout main

Optionally cut a version tag at the same commit (`git tag vX.Y.Z && git push
origin vX.Y.Z`) for a historical record. If a bad change reaches `stable`,
roll back by force-moving `stable` to the previous good commit — consumers
follow the branch, so recovery is one push.

Rationale: `main` used to be the live deploy channel — any merge silently
overwrote `bc-mcp-bridge.js` (which handles S2S credentials) on every
developer machine at next session start. The `stable` gate separates "CI
accepted it" from "the organization runs it".

## Known deltas to close before activating the Entry flow

1. **`custom/skills/` is empty.** The CURABIS review pass lives in the
   per-project `bcquality.agent.md` template, which Entry's skill discovery
   (`*/skills/**/*.md`) never sees. Before wiring an orchestrator, move or
   mirror the CURABIS review skill into `custom/skills/review/`.
2. **Two index generators.** The session model's `INDEX.md` is generated by
   `sync-bcquality-knowledge.ps1`'s own frontmatter parser; the Entry flow uses
   `tools/Build-KnowledgeIndex.ps1` (CI-validated, schema in lockstep with the
   Source contract). Converge on the official generator.
3. **Layer precedence is not mirrored.** The READ contract defines what wins
   when layers conflict; the machine mirror carries knowledge only, so sessions
   have no formal precedence rule.
