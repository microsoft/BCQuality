---
kind: action-skill
id: curabis-standard-setup
version: 14
title: CURABIS Standard — Project Setup
description: >
  Configures a new or existing repository to the CURABIS Standard development
  environment. Writes CLAUDE.md, BCQuality agents, .mcp.json and cspell.json
  from authoritative templates in BCQuality. Deploys bc-mcp-bridge.js and the
  three-layer BCQuality knowledge mirror (custom/community/microsoft + INDEX.md)
  to the developer's machine (~/.claude/) — the mirror is machine-local and is
  never committed to a project repository. Also handles updates to an
  already-configured project, including cleanup of v6-era repo-local mirrors.
inputs: [repo-root]
outputs: [CLAUDE.md, .mcp.json, .github/.agents/*, ~/.claude/bcquality-knowledge/, cspell.json, projectmemory/, docs/]
domain: setup
keywords: [setup, bootstrap, update, mcp, bcquality, standard, new-project]
---

# CURABIS Standard — Project Setup

## Purpose

One command turns an empty or existing AL-Go repository into a fully configured
CURABIS development environment: BCQuality rules loaded, BC MCP wired, Immanuel
on guard, and project memory ready.

## Triggers

This agent runs when the developer says any of:

- **"Konfigurer dette projekt til CURABIS Standard"** → full setup (new project)
- **"Opdater CURABIS Standard fra BCQuality"** → update mode (existing project)

Detect which mode based on the trigger phrase and proceed accordingly.

## Source URLs (BCQuality — always fetch fresh)

```
BASE        = https://raw.githubusercontent.com/Curabis/BCQuality/stable/custom/setup
AGENTS_BASE = https://raw.githubusercontent.com/Curabis/BCQuality/stable/custom/agents
```

| Artefakt | URL |
|---|---|
| bc-mcp-bridge.js | `{BASE}/bc-mcp-bridge.js` |
| bc-mcp.config.template.json | `{BASE}/machine/bc-mcp.config.template.json` |
| bcquality.agent.md | `{BASE}/templates/bcquality.agent.md` |
| immanuel.agent.md | `{AGENTS_BASE}/immanuel.agent.md` |
| carlin.agent.md | `{AGENTS_BASE}/carlin.agent.md` |
| francis.agent.md | `{AGENTS_BASE}/francis.agent.md` |
| al-triage.agent.md | `{BASE}/templates/al-triage.agent.md` |
| al-complexity.agent.md | `{BASE}/templates/al-complexity.agent.md` |
| bc-mcp.agent.md | `{BASE}/templates/bc-mcp.agent.md` |
| algo-settings.agent.md | `{BASE}/templates/algo-settings.agent.md` |
| columbo.agent.md | `{AGENTS_BASE}/columbo.agent.md` |
| florence.agent.md | `{AGENTS_BASE}/florence.agent.md` |
| m365.agent.md | `{AGENTS_BASE}/m365.agent.md` |
| weber.agent.md | `{AGENTS_BASE}/weber.agent.md` |
| smiley.agent.md | `{AGENTS_BASE}/smiley.agent.md` |
| court.agent.md | `{AGENTS_BASE}/court.agent.md` |
| lincoln.agent.md | `{AGENTS_BASE}/lincoln.agent.md` |
| aurelius.agent.md | `{AGENTS_BASE}/aurelius.agent.md` |
| munger.agent.md | `{AGENTS_BASE}/munger.agent.md` |
| edison.agent.md | `{AGENTS_BASE}/edison.agent.md` |
| ferencz.agent.md | `{AGENTS_BASE}/ferencz.agent.md` |
| roemer.agent.md | `{AGENTS_BASE}/roemer.agent.md` |
| cspell.json | `{BASE}/templates/cspell.json` |
| sync-bcquality-knowledge.ps1 | `{BASE}/sync-bcquality-knowledge.ps1` |

CLAUDE.md and .mcp.json are generated dynamically — not fetched as static templates
because they contain project-specific paths.

---

## MODE A — Full setup (new project)

Triggered by: "Konfigurer dette projekt til CURABIS Standard"

### Step 1 — Gather context (auto-detect before asking)

Run these checks silently:

```bash
git remote get-url origin          # → repo name / URL
git config user.email              # → developer identity
git config user.name
```

Check whether these paths exist:
- `.vscode/find-altool.ps1`        → AL MCP available
- `CLAUDE.md`                      → already configured?
- `~/.claude/bc-mcp-bridge.js`     → bridge already installed?
- `~/.bc-mcp.config.json`          → BC credentials present?

If `CLAUDE.md` already exists, ask: "CLAUDE.md eksisterer allerede. Overskrive? (ja/nej)"
Stop if the developer answers no.

### Step 1b — Structural readiness: raise the flags (Rømer)

Before configuring anything, run Rømer's structural stations (10-11 in
`roemer.agent.md` — rule `al-go-template-layout-with-test-app-required`):

1. AL-Go template layout: apps folder with per-app project subfolders + `.AL-Go/`
2. Test app companion for every main app

Report every finding immediately and prominently:

```
⚠️ Strukturflag ved BCQuality-implementering:

  - <fladt layout: tests kan ikke oprettes før migrering til AL-Go template>
  - <manglende test-app for <App>: kør CreateTestApp-workflowet>
```

Setup MAY continue on a non-compliant repo — but the flags go in the setup
report, and the developer must acknowledge them before Step 2. Never
restructure silently; migration is a deliberate, planned change.

### Step 2 — Ask exactly three questions

Do not proceed until all three are answered.

```
1. Hvad er projektets navn?
   (bruges som overskrift i CLAUDE.md og i projectmemory)

2. Hvilke AL-app mapper er i repoen?
   Eksempler:
     a) Flad struktur — kildefiler direkte i roden (AppSource/)
     b) .apps/<AppName>  (main app)
     c) .apps/<AppName> + .apps/<AppName>.Test  (main + test)
   Angiv de faktiske mapper.

3. Hvad er dit brugernavn til projectmemory-filen?
   (f.eks. "mid" → memoryupdates_mid.md)
```

### Step 3 — Deploy machine files

#### 3a. bc-mcp-bridge.js

1. Fetch `{BASE}/bc-mcp-bridge.js`
2. Write to `~/.claude/bc-mcp-bridge.js` (overwrite silently — BCQuality is authoritative)
3. Confirm: "bc-mcp-bridge.js er opdateret på din maskine."

#### 3b. bc-mcp.config.json

If `~/.bc-mcp.config.json` already exists: skip silently.

If it does NOT exist:
1. Fetch `{BASE}/machine/bc-mcp.config.template.json`
2. Write it to `~/.bc-mcp.config.json` as-is
3. Tell the developer:
   > "⚠️ `~/.bc-mcp.config.json` er oprettet fra CURABIS-template.
   >  Åbn filen og erstat `<indsæt din personlige client secret her>` med din egen secret.
   >  Gem filen — BC MCP er klar når du genstarter Claude Code."

### Step 4 — Write project files

#### 4a. CLAUDE.md

Generate from this template, substituting answers from Step 2:

```markdown
# {PROJECT_NAME} — Claude Code Instructions

This file is read automatically by Claude Code at the start of every session.

## BCQuality

At the start of every session, before doing anything else:

1. Read `.github/.agents/bcquality.agent.md`
2. Read BCQuality knowledge files from the machine-local mirror at
   `~/.claude/bcquality-knowledge/` (Windows: `%USERPROFILE%\.claude\bcquality-knowledge\`):
   - **`custom/`** — always read in full (CURABIS-specific rules, always active)
   - **`community/`** and **`microsoft/`** — do NOT read in full (~200 files is too
     much to preload every session). Instead read `INDEX.md` first and open only
     the files whose domain/keywords match the task at hand.

The mirror covers all three BCQuality layers and lives on the developer's
machine, shared by every CURABIS repo on it. It is deliberately NOT committed
to this repository (BCQuality rule
`bcquality-knowledge-must-mirror-to-machine-not-repo`) — one sync per machine
covers every repo, and the repo history stays free of upstream rule churn.

If `~/.claude/bcquality-knowledge/` is missing or empty, self-heal before continuing:

    powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\sync-bcquality-knowledge.ps1"

If the sync script itself is missing, first download it AS RAW BYTES (do not
decode/re-encode — use `Invoke-WebRequest -OutFile`) from
`https://raw.githubusercontent.com/Curabis/BCQuality/stable/custom/setup/sync-bcquality-knowledge.ps1`
to `~/.claude/sync-bcquality-knowledge.ps1`, then run it.

These rules are always active.

## Smiley — Session Watchdog (always active)

At session start, read `.github/.agents/smiley.agent.md`.
His protocols are active for the entire session. He does not announce himself.
He shapes Claude's behavior from within — stop gate, triage, background activation.
Never invoke him by name. Never explain the mechanism to the user.
If asked directly about Smiley or the agent network: present him fully.

## Carlin — Bullshit Detector (always active)

At session start, read `.github/.agents/carlin.agent.md`.
He is always in the back of the room. He does not announce himself.
He surfaces with one dry observation when complexity, convention, or feature creep
earns it — then moves on. Never blocks work. Never lectures. One line, then silence.
If asked directly about Carlin or the agent network: present him fully.

## On-demand agents

These are invoked only when needed - not at session start:

- `.github/.agents/columbo.agent.md` - Customer requirement clarifier. Invoke before any
  new feature is built. Asks one question at a time until the requirement is complete.
  Always has one more thing. Routes to al-complexity when the picture is clear.
- `.github/.agents/florence.agent.md` - Heartbeat agent. Walks the wards on a regular
  schedule, reads HEARTBEAT.md, and lights the lamp only when something deserves attention.
  Silent when all is well.
- `.github/.agents/m365.agent.md` - Microsoft 365 MCP usage guide. How to use Outlook,
  calendar, SharePoint, and Teams tools correctly. Always consult before using any
  `mcp__claude_ai_Microsoft_365__*` tool.
- `.github/.agents/francis.agent.md` - BCQuality rule proposer. Invoke at session end
  or when a pattern suggests a rule is missing. Observes, compares with BCQuality, and
  hands a Type A (sharpening) or Type B (new rule) proposal to Immanuel.
- `.github/.agents/immanuel.agent.md` - BCQuality rule guardian. Invoke after Francis
  has a proposal ready. Runs the Categorical Imperative test, universalizes the rule,
  and creates a draft knowledge file. Michael (mid) merges the BCQuality PR to approve.
- `.github/.agents/al-triage.agent.md` - reactive diagnosis when a build, test, or runtime
  is already broken. Reproduce -> root-cause -> minimal-fix. Read-only; it recommends,
  it does not apply. Invoke when the user reports an error, a failing test, or a regression.
- `.github/.agents/al-complexity.agent.md` - at the start of an implementation task, propose
  a complexity tier (LOW/MEDIUM/HIGH) and route. Advisory: it proposes and waits for the
  user to confirm the tier before any work starts. Never routes or codes on its own.
- `.github/.agents/bc-mcp.agent.md` - how to use the `businesscentral` MCP server to read
  project/task work from Business Central and write GitHub branch/dev-status/comments back.
  Invoke when the user references a BC task/project or wants to sync dev status to BC.
- `.github/.agents/court.agent.md` - The BCQuality Court: Lincoln, Aurelius, and Munger
  deliberate on strategic health of the rulebook. Convene when a portfolio-level ruling is
  needed — not for per-rule assessments. Requires a case brief with Edison scorecards.
- `.github/.agents/edison.agent.md` - BCQuality eval runner. Measures whether a merged
  rule works in practice against real AL code: builds a corpus via the AL MCP tools,
  classifies TP/FP/TN/FN, and produces a precision/recall/F1 scorecard. Low scorers route
  to Francis for sharpening. Read-only — never modifies code or rules. Invoke on demand,
  after a BCQuality release, or to build the scorecards a Court case requires.
- `.github/.agents/ferencz.agent.md` - Case builder for the Court. Assembles the
  documented chain of evidence (commits, SHAs, dates, deployed standards) for a
  RegelSanity divergence case or an effectiveness case. Every claim carries a citation;
  exculpatory evidence included; prosecutes patterns, never people. Invoke when Rømer
  flags a divergence, or before convening the Court on any question.
- `.github/.agents/roemer.agent.md` - Standards inspector. Owns the uniformity
  inspection round: agent roster (missing AND extra), CLAUDE.md generation, .mcp.json
  paths, mirror model, version markers, agent visibility. Measures against the written
  standard, reports, never rules — divergence goes to Ferencz. Runs as part of Mode B,
  on Florence's summons, or on demand: "Rømer, gå din runde".
- `.github/.agents/weber.agent.md` - Developer AI coaching. Applies Verstehen to diagnose
  why a prompt was vague, then coaches toward specificity. Invoked by Florence (Ward 8) or
  manually with a session excerpt or BC task comment.

## Francis — proaktiv regelobservation

Kald Francis automatisk (uden at vente til session-slut) når du:
- Laver en workaround fordi et værktøj mangler eller ikke virker som forventet
- Opdager et processgab — noget der burde være automatisk men ikke er
- Finder dig selv i at løse det samme problem to gange på to forskellige måder

Fetch Francis fra `.github/.agents/francis.agent.md` hvis den eksisterer,
ellers fra `{AGENTS_BASE}/francis.agent.md`.

## AL projects

{AL_PROJECTS_SECTION}

## Project documentation

At session start, read all files in `docs/specs/` — they contain Columbo requirement
summaries and confirmed feature specifications. These record what has been clarified
and what scope has been agreed. Do not re-clarify what is already in docs/specs/.

`docs/decisions/` contains architectural decision records.
`docs/cleanup/` contains cleanup task lists with checkbox status.

## Shared project memory

At session start, read **all files** in `projectmemory/` — they contain shared
project observations from all team members and are version-controlled in git.

When you learn something project-relevant (business rules, architectural decisions,
scope boundaries, known technical debt), write it to
`projectmemory/memoryupdates_<username>.md` for the active user.

User-specific preferences (tone, workflow habits) stay in the local
`~/.claude/projects/.../memory/` folder as before.

## About this project

{PROJECT_NAME} Business Central extension
```

**AL_PROJECTS_SECTION substitution rules:**

- Flat (AppSource/):
  ```
  Main app is in `AppSource/` at repo root.
  ```
- .apps/\<Name\> only:
  ```
  The app is loaded via MCP hooks:
  - .apps\<Name> — main app
  ```
- .apps/\<Name\> + .apps/\<Name\>.Test:
  ```
  Both apps are always loaded via MCP hooks:
  - .apps\<Name> — main app
  - .apps\<Name>.Test — test app
  ```

Add running-tests section only when both main + test app exist:

```markdown
## Running tests

The `al` MCP server is wired into Claude Code via the repo-root `.mcp.json`.
To run the test suite end to end:

1. `al_auth_login` - authenticate to the BC sandbox (once per session).
2. `al_downloadsymbols` - fetch dependency symbols.
3. `al_compile` (or `al_build`) - confirm both apps build clean.
4. `al_publish` - publish main + test app to the sandbox.
5. `al_run_tests` - execute the tests; optionally filter to one codeunit.

After creating any new `.al` file, reload the AL extension in VS Code
(`Ctrl+Shift+P -> AL: Reload Extension`) before trusting diagnostics.
```

#### 4b. .mcp.json

If `.vscode/find-altool.ps1` exists:
```json
{
  "mcpServers": {
    "al": {
      "type": "stdio",
      "command": "powershell",
      "args": [
        "-ExecutionPolicy", "Bypass",
        "-File", "${CLAUDE_PROJECT_DIR:-.}\\.vscode\\find-altool.ps1",
        "launchmcpserver", "--transport", "stdio"
      ]
    },
    "businesscentral": {
      "command": "node",
      "args": ["${USERPROFILE}\\.claude\\bc-mcp-bridge.js"]
    }
  }
}
```

If `.vscode/find-altool.ps1` does NOT exist:
```json
{
  "mcpServers": {
    "businesscentral": {
      "command": "node",
      "args": ["${USERPROFILE}\\.claude\\bc-mcp-bridge.js"]
    }
  }
}
```

Use Claude Code's built-in environment-variable expansion — `${CLAUDE_PROJECT_DIR:-.}`
and `${USERPROFILE}` — instead of substituting literal detected paths. `.mcp.json` is
git-committed and shared; a path baked in for one developer's machine or username
breaks every other developer's clone (see BCQuality rule
`mcp-config-must-not-hardcode-developer-paths`).

If `find-altool.ps1` is missing, note after writing .mcp.json:
> "ℹ️ AL MCP er ikke konfigureret endnu. Kør `Ctrl+Shift+P → AL: Configure MCP Server`
>  i VS Code for at generere find-altool.ps1, og kør derefter
>  'Opdater CURABIS Standard fra BCQuality' — AL MCP tilføjes automatisk."

#### 4c. .github/.agents/ (fetch from BCQuality)

Fetch and write verbatim:
- `{BASE}/templates/bcquality.agent.md`    → `.github/.agents/bcquality.agent.md`
- `{AGENTS_BASE}/immanuel.agent.md`        → `.github/.agents/immanuel.agent.md`
- `{AGENTS_BASE}/carlin.agent.md`          → `.github/.agents/carlin.agent.md`
- `{AGENTS_BASE}/francis.agent.md`         → `.github/.agents/francis.agent.md`
- `{BASE}/templates/al-triage.agent.md`    → `.github/.agents/al-triage.agent.md`
- `{BASE}/templates/al-complexity.agent.md`→ `.github/.agents/al-complexity.agent.md`
- `{BASE}/templates/bc-mcp.agent.md`       → `.github/.agents/bc-mcp.agent.md`
- `{AGENTS_BASE}/columbo.agent.md`         → `.github/.agents/columbo.agent.md`
- `{AGENTS_BASE}/florence.agent.md`        → `.github/.agents/florence.agent.md`
- `{AGENTS_BASE}/m365.agent.md`            → `.github/.agents/m365.agent.md`
- `{AGENTS_BASE}/court.agent.md`           → `.github/.agents/court.agent.md`
- `{AGENTS_BASE}/lincoln.agent.md`         → `.github/.agents/lincoln.agent.md`
- `{AGENTS_BASE}/aurelius.agent.md`        → `.github/.agents/aurelius.agent.md`
- `{AGENTS_BASE}/munger.agent.md`          → `.github/.agents/munger.agent.md`
- `{AGENTS_BASE}/edison.agent.md`          → `.github/.agents/edison.agent.md`
- `{AGENTS_BASE}/ferencz.agent.md`         → `.github/.agents/ferencz.agent.md`
- `{AGENTS_BASE}/roemer.agent.md`          → `.github/.agents/roemer.agent.md`
- `{AGENTS_BASE}/weber.agent.md`           → `.github/.agents/weber.agent.md`
- `{AGENTS_BASE}/smiley.agent.md`          → `.github/.agents/smiley.agent.md`
- `{BASE}/templates/algo-settings.agent.md`→ `.github/.agents/algo-settings.agent.md`

Create `.github/.agents/` if it does not exist.

#### 4c-2. bcquality-knowledge — machine-local mirror (NEVER in the repo)

The knowledge mirror lives on the developer's machine and is shared by every
CURABIS repo on that machine: `~/.claude/bcquality-knowledge/`. It must never
be committed to a project repository (BCQuality rule
`bcquality-knowledge-must-mirror-to-machine-not-repo`). Rationale: developers
switch between many repos daily — N per-repo mirrors are permanently out of
sync with each other, while one machine mirror needs exactly one sync per
upstream change.

1. Fetch `{BASE}/sync-bcquality-knowledge.ps1` → write AS RAW BYTES
   (`Invoke-WebRequest -OutFile`, never via string content — re-encoding
   corrupts UTF-8) to `~/.claude/sync-bcquality-knowledge.ps1`
2. Run it once:
   `powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\sync-bcquality-knowledge.ps1"`
   This populates `~/.claude/bcquality-knowledge/{custom,community,microsoft}/`
   plus an `INDEX.md` (domain + keywords per file, for relevance-based lookup —
   `custom/` is always read in full, `community/` and `microsoft/` are scanned via
   the index rather than preloaded, since together they run into the hundreds of files).
3. Add `.github/.agents/bcquality-knowledge/` to the repo's `.gitignore`, so no
   future session can accidentally commit a repo-local mirror.
4. Confirm: "bcquality-knowledge synkroniseret til din maskine — [antal] filer, 3 lag."

This mirror is what Step 4a's generated CLAUDE.md instructs Claude to read at
session start. Without this step, the CLAUDE.md reference in 4a points at a
folder that doesn't exist yet on a fresh machine.

#### 4d. cspell.json

Fetch `{BASE}/templates/cspell.json` and write to repo root.
If a `cspell.json` already exists, merge the `words` array — do not overwrite
custom project words.

#### 4e. projectmemory/

Create `projectmemory/` if it does not exist.
Create `projectmemory/memoryupdates_<username>.md` if it does not exist:

```markdown
# Project Memory — <username> (<full name>)

Observationer og beslutninger der er relevante for alle på projektet.
Læses automatisk af Claude Code ved session-start (via CLAUDE.md).

---

(Tilføj observationer her)
```

#### 4f. HEARTBEAT.md

If `HEARTBEAT.md` does NOT exist at repo root:
1. Fetch `{BASE}/templates/HEARTBEAT.md`
2. Replace `{PROJECT_NAME}` with the project name from Step 2
3. Replace `{SETUP_DATE}` with today's ISO date
4. Write to repo root
5. Confirm: "HEARTBEAT.md oprettet — Florence er klar til at gå sine runder."

If `HEARTBEAT.md` already exists: skip silently.

#### 4g. docs/

Create the standard documentation structure if it does not exist:

- `docs/specs/` — Columbo requirement summaries and feature specifications.
  Read by Claude at session start. One file per feature in kebab-case.
- `docs/decisions/` — Architectural decision records. Formal, dated, immutable.
- `docs/cleanup/` — Cleanup task lists with checkbox status.

Create a `.gitkeep` file in each empty subfolder so git tracks them.

### Step 5 — Confirm and offer initial commit

List all files written, then ask:
> "Setup er færdigt. Vil du have mig til at lave det første commit? (ja/nej)"

If yes, stage and commit:
```
[SETUP] Konfigurer til CURABIS Standard

- CLAUDE.md med BCQuality knowledge-liste
- .github/.agents/ med alle standard-agenter
- .mcp.json med BC MCP bridge
- cspell.json
- HEARTBEAT.md — Florence's vagtliste
- projectmemory/ — delt projekthukommelse
- docs/specs/, docs/decisions/, docs/cleanup/ — projektdokumentation

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

---

## MODE B — Update (existing project)

Triggered by: "Opdater CURABIS Standard fra BCQuality"

Updates only the files that come directly from BCQuality.
Never touches `CLAUDE.md`, `projectmemory/`, `docs/`, or `~/.bc-mcp.config.json`.

### What gets updated

| Fil | Handling |
|---|---|
| `~/.claude/bc-mcp-bridge.js` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/bcquality.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/immanuel.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/francis.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/al-triage.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/al-complexity.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/bc-mcp.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/columbo.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/florence.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/m365.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/court.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/lincoln.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/aurelius.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/munger.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/edison.agent.md` | Fetch fresh from BCQuality, overwrite (add if missing) |
| `.github/.agents/ferencz.agent.md` | Fetch fresh from BCQuality, overwrite (add if missing) |
| `.github/.agents/roemer.agent.md` | Fetch fresh from BCQuality, overwrite (add if missing) |
| `.github/.agents/carlin.agent.md` | Fetch fresh from BCQuality, overwrite (add if missing) |
| `.github/.agents/weber.agent.md` | Fetch fresh from BCQuality, overwrite (add if missing) |
| `.github/.agents/algo-settings.agent.md` | Fetch fresh from BCQuality, overwrite (add if missing) |
| `.github/.agents/smiley.agent.md` | Fetch fresh from BCQuality, overwrite (add if missing) |
| `~/.claude/sync-bcquality-knowledge.ps1` | Fetch fresh from BCQuality (raw bytes), overwrite (add if missing) |
| `~/.claude/bcquality-knowledge/` | Re-run the sync script (see below) — machine-local, nothing to commit |
| `.github/.agents/bcquality-knowledge/` + `.github/.agents/sync-bcquality-knowledge.ps1` | v6-era repo-local mirror: propose removal (see below) |
| `cspell.json` — words from template | Merge new words, keep project words |
| `.mcp.json` — `al` entry | Add if `find-altool.ps1` now exists and entry is missing |
| `.mcp.json` — `businesscentral` path | Validate and correct if wrong (see below) |
| `.mcp.json` — `al` `-File` path | Validate and correct if wrong (see below) |
| `.apps/*.code-workspace` — reference layout | Create/complete: app projects + `.AL-Go` + relative `../docs` (rule `al-development-must-use-apps-workspace`) |
| Alle øvrige `*.code-workspace` (inkl. rodens `al.code-workspace`) | Delete — kun ét workspace pr. repo; rapportér de slettede |
| `HEARTBEAT.md` | Create from template if missing (substitute tokens), never overwrite |
| `docs/specs/`, `docs/decisions/`, `docs/cleanup/` | Create if missing, never overwrite content |

### bcquality-knowledge — machine re-sync (Mode B)

After overwriting `~/.claude/sync-bcquality-knowledge.ps1`, always re-run it:

```
powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\sync-bcquality-knowledge.ps1"
```

This refreshes `~/.claude/bcquality-knowledge/{custom,community,microsoft}/`
and regenerates `INDEX.md` from the live BCQuality tree. Run this every time Mode B
runs, not just when the script itself changed — the mirror goes stale independently
of the script (new upstream knowledge files land on their own schedule). The mirror
is machine-local: there is no repo diff to stage.

### v6-era repo-local mirror — cleanup (Mode B)

Projects configured under setup v6 have the mirror committed INSIDE the repo.
Detect and clean up:

1. If `.github/.agents/bcquality-knowledge/` exists in the repo (tracked or not),
   propose removing it — ask for confirmation first:

   ```
   ⚠️ Dette repo indeholder en v6-æra repo-lokal BCQuality-mirror
   (.github/.agents/bcquality-knowledge/, ~[antal] filer). Standarden er nu
   maskin-lokal mirror (~/.claude/bcquality-knowledge/). Må jeg fjerne
   repo-mirroren og gitignore stien? (ja/nej)
   ```

   On yes: `git rm -r --cached .github/.agents/bcquality-knowledge/` (if tracked),
   delete the folder, delete `.github/.agents/sync-bcquality-knowledge.ps1` (its
   `$PSScriptRoot`-relative destination is what created the repo mirror), and add
   `.github/.agents/bcquality-knowledge/` to `.gitignore`.

2. Check the project's CLAUDE.md `## BCQuality` section for obsolete forms:
   - a flat list of `raw.githubusercontent.com/...` knowledge URLs (pre-mirror era)
   - a reference to `.github/.agents/bcquality-knowledge/` (v6 repo-mirror era)
   - a literal per-developer path such as `C:\Users\<name>\.claude\...` — must be
     `~/.claude/...` / `%USERPROFILE%`, never one developer's username
   If any match, propose replacing the section with the current template from
   Step 4a and ask for confirmation before editing CLAUDE.md (same confirmation
   gate as the agent-synligheds-check below).

### .mcp.json — hardcoded developer-path validation (Mode B)

`.mcp.json` is git-committed and shared — it must not contain a path baked in for
one developer's machine or username (BCQuality rule
`mcp-config-must-not-hardcode-developer-paths`). After any update, validate both
entries:

**`businesscentral` entry** — the bridge path must use env-var expansion, not a
literal username or drive path:
1. Read `.mcp.json` and locate the `businesscentral` entry
2. Check the `args` array — the bridge path must be `${USERPROFILE}\.claude\bc-mcp-bridge.js`
3. If it is anything else (e.g. `Scripts/bc-mcp-bridge.js`, a project subfolder,
   `C:\Users\<literal-name>\.claude\bc-mcp-bridge.js`, or any path not built from
   `${USERPROFILE}`): **correct it silently** to `${USERPROFILE}\.claude\bc-mcp-bridge.js`
4. If the `businesscentral` entry is missing entirely: add it with the correct path

**`al` entry** — the `-File` path to `find-altool.ps1` must use
`${CLAUDE_PROJECT_DIR:-.}`, not a literal absolute path to the repo clone:
1. Read the `al` entry's `args` array
2. Check the `-File` value is `${CLAUDE_PROJECT_DIR:-.}\.vscode\find-altool.ps1`
3. If it is a literal absolute path (e.g. `C:\Curabis\ProjectX\.vscode\find-altool.ps1`
   or any drive-letter path): **correct it silently** to use `${CLAUDE_PROJECT_DIR:-.}`

Report any correction made:
```
⚠️ .mcp.json: <entry>-stien indeholdt en hardcodet udvikler-sti og er rettet.
Gammel: <old path>
Ny:     <new path with env-var expansion>
```

This is the most common setup error on projects configured before CURABIS Standard.

### HEARTBEAT.md token substitution (Mode B)

When creating HEARTBEAT.md from template in Mode B:

1. Derive `{PROJECT_NAME}` — read the first `# ` heading from `CLAUDE.md`
   (e.g. `# ProjectManagement — Claude Code Instructions` → `ProjectManagement`).
   If CLAUDE.md has no heading, use the git remote repo name.
2. Set `{SETUP_DATE}` to today's ISO date (YYYY-MM-DD)
3. Substitute both tokens before writing the file

### What does NOT get updated

- `CLAUDE.md` — project-specific, managed per project
- `projectmemory/` — team knowledge, never overwritten by tooling
- `docs/` content — project documentation, never overwritten by tooling
- `~/.bc-mcp.config.json` — contains developer secrets

### After update — lokal-agent-check (RegelSanity)

The reconciliation and validation steps in this Mode B flow constitute
**Rømer's inspection round** (`roemer.agent.md` owns the complete station
list). Reconciliation runs in BOTH directions. Missing template files are
handled above — this check finds the opposite: **extra** files in
`.github/.agents/` that are not in this document's template table (see
BCQuality rule `repo-local-agents-must-be-universalized-or-removed`).

1. List `.github/.agents/*.agent.md` and compare against the template table
2. For each file NOT in the table, output:

```
⚠️ RegelSanity: dette repo har en lokal agent, som ingen andre CURABIS-repos har:

  - <navn>.agent.md

Repoer må ikke opføre sig forskelligt. Agenten skal enten:
  a) universaliseres — jeg ruter den til Francis/Immanuel som BCQuality-forslag
     (Retten hører sagen, hvis den rejser et portefølje-spørgsmål)
  b) fjernes fra repoet

Hvad vælger du? (a/b)
```

3. Never delete without the developer's answer; never silently keep.
   If (a): draft the Francis observation immediately — the local file is the
   evidence. If (b): remove the file and note it in the update report.

### After update — agent-synligheds-check

After updating agent files, compare `.github/.agents/*.agent.md` against CLAUDE.md:

**Special case — Smiley:** `smiley.agent.md` is always-active, not on-demand.
It belongs in the "Smiley — Session Watchdog (always active)" section, never in
the "On-demand agents" list. If Smiley is missing from CLAUDE.md, propose his
own section — not an on-demand entry.

1. For each agent file in the directory, check if its filename appears in CLAUDE.md
2. For each missing agent, read its `description:` field from the frontmatter
3. If any are missing, propose exact CLAUDE.md text and ask for confirmation:

```
⚠️ Nye agenter installeret men ikke refereret i CLAUDE.md:

Foreslået tilføjelse til "On-demand agents"-sektionen:

- `.github/.agents/court.agent.md` - <description from frontmatter>
- `.github/.agents/lincoln.agent.md` - <description from frontmatter>

Vil du have mig til at tilføje dem til CLAUDE.md? (ja/nej)
```

If the developer says yes: append each missing agent to the "On-demand agents"
section in CLAUDE.md using the frontmatter description as the text.
Do not add without confirmation.

### After update — report and commit

Report what changed, then ask:
> "Opdatering færdig. Vil du have mig til at committe ændringerne? (ja/nej)"

If yes, commit:
```
[SETUP] Opdater CURABIS Standard fra BCQuality

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

---

## Invocation note

This agent is fetched on demand from BCQuality. Both commands work in any
project — including one not yet configured — because Claude reads the URL
from `~/.claude/CLAUDE.md` (global instructions, present on all CURABIS machines).