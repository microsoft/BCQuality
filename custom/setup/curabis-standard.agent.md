---
kind: action-skill
id: curabis-standard-setup
version: 3
title: CURABIS Standard — Project Setup
description: >
  Configures a new or existing repository to the CURABIS Standard development
  environment. Writes CLAUDE.md, BCQuality agents, .mcp.json and cspell.json
  from authoritative templates in BCQuality. Deploys bc-mcp-bridge.js to the
  developer's machine. Also handles updates to an already-configured project.
inputs: [repo-root]
outputs: [CLAUDE.md, .mcp.json, .github/.agents/*, cspell.json, projectmemory/, docs/]
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
BASE        = https://raw.githubusercontent.com/Curabis/BCQuality/main/custom/setup
AGENTS_BASE = https://raw.githubusercontent.com/Curabis/BCQuality/main/custom/agents
```

| Artefakt | URL |
|---|---|
| bc-mcp-bridge.js | `{BASE}/bc-mcp-bridge.js` |
| bc-mcp.config.template.json | `{BASE}/machine/bc-mcp.config.template.json` |
| bcquality.agent.md | `{BASE}/templates/bcquality.agent.md` |
| immanuel.agent.md | `{BASE}/templates/immanuel.agent.md` |
| francis.agent.md | `{BASE}/templates/francis.agent.md` |
| al-triage.agent.md | `{BASE}/templates/al-triage.agent.md` |
| al-complexity.agent.md | `{BASE}/templates/al-complexity.agent.md` |
| bc-mcp.agent.md | `{BASE}/templates/bc-mcp.agent.md` |
| algo-settings.agent.md | `{BASE}/templates/algo-settings.agent.md` |
| columbo.agent.md | `{AGENTS_BASE}/columbo.agent.md` |
| florence.agent.md | `{AGENTS_BASE}/florence.agent.md` |
| m365.agent.md | `{AGENTS_BASE}/m365.agent.md` |
| weber.agent.md | `{AGENTS_BASE}/weber.agent.md` |
| cspell.json | `{BASE}/templates/cspell.json` |

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
2. Read BCQuality knowledge files from local cache (no network — fast):
   ```
   C:\Users\mid\.claude\bcquality-knowledge\architecture\*.md
   C:\Users\mid\.claude\bcquality-knowledge\testing\*.md
   C:\Users\mid\.claude\bcquality-knowledge\mcp\*.md
   ```
   The cache is populated automatically when BCQuality updates (via global CLAUDE.md
   auto-update). If the cache is missing or empty on first run, the auto-update will
   populate it. Do not fetch URLs manually unless explicitly asked.

These rules are always active.

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
- `.github/.agents/weber.agent.md` - Developer AI coaching. Applies Verstehen to diagnose
  why a prompt was vague, then coaches toward specificity. Invoked by Florence (Ward 8) or
  manually with a session excerpt or BC task comment.

## Francis — proaktiv regelobservation

Kald Francis automatisk (uden at vente til session-slut) når du:
- Laver en workaround fordi et værktøj mangler eller ikke virker som forventet
- Opdager et processgab — noget der burde være automatisk men ikke er
- Finder dig selv i at løse det samme problem to gange på to forskellige måder

Fetch Francis fra `.github/.agents/francis.agent.md` hvis den eksisterer,
ellers fra `{BASE}/templates/francis.agent.md`.

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
        "-File", "<ABS_PATH_TO_VSCODE>/find-altool.ps1",
        "launchmcpserver", "--transport", "stdio"
      ]
    },
    "businesscentral": {
      "command": "node",
      "args": ["C:\\Users\\<USERNAME>\\.claude\\bc-mcp-bridge.js"]
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
      "args": ["C:\\Users\\<USERNAME>\\.claude\\bc-mcp-bridge.js"]
    }
  }
}
```

Substitute `<ABS_PATH_TO_VSCODE>` and `<USERNAME>` from detected values.

If `find-altool.ps1` is missing, note after writing .mcp.json:
> "ℹ️ AL MCP er ikke konfigureret endnu. Kør `Ctrl+Shift+P → AL: Configure MCP Server`
>  i VS Code for at generere find-altool.ps1, og kør derefter
>  'Opdater CURABIS Standard fra BCQuality' — AL MCP tilføjes automatisk."

#### 4c. .github/.agents/ (fetch from BCQuality)

Fetch and write verbatim:
- `{BASE}/templates/bcquality.agent.md`    → `.github/.agents/bcquality.agent.md`
- `{BASE}/templates/immanuel.agent.md`     → `.github/.agents/immanuel.agent.md`
- `{BASE}/templates/francis.agent.md`      → `.github/.agents/francis.agent.md`
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

Create `.github/.agents/` if it does not exist.

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
| `cspell.json` — words from template | Merge new words, keep project words |
| `.mcp.json` — `al` entry | Add if `find-altool.ps1` now exists and entry is missing |
| `.mcp.json` — `businesscentral` path | Validate and correct if wrong (see below) |
| `HEARTBEAT.md` | Create from template if missing (substitute tokens), never overwrite |
| `docs/specs/`, `docs/decisions/`, `docs/cleanup/` | Create if missing, never overwrite content |

### .mcp.json — businesscentral path validation (Mode B)

The `businesscentral` MCP server entry must point to the global bridge file,
not a project-local path. After any update, validate `.mcp.json`:

1. Read `.mcp.json` and locate the `businesscentral` entry
2. Check the `args` array — the bridge path must be:
   `C:\Users\<USERNAME>\.claude\bc-mcp-bridge.js`
   where `<USERNAME>` is the current Windows username (`$env:USERNAME`)
3. If the path points anywhere else (e.g. `Scripts/bc-mcp-bridge.js`,
   a project subfolder, or any path not under `~/.claude/`): **correct it silently**
4. If `businesscentral` entry is missing entirely: add it with the correct path
5. Report any correction made:
   ```
   ⚠️ .mcp.json: businesscentral-stien var forkert og er rettet.
   Gammel: <old path>
   Ny:     C:\Users\<USERNAME>\.claude\bc-mcp-bridge.js
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

### After update — agent-synligheds-check

After updating agent files, compare `.github/.agents/*.agent.md` against CLAUDE.md:

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