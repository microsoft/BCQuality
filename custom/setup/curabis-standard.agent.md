---
kind: action-skill
id: curabis-standard-setup
version: 24
title: CURABIS Standard — Project Setup
description: >
  Configures a new or existing repository to the CURABIS Standard development
  environment. Writes a slim project CLAUDE.md, cspell.json, and the two
  repo-local exceptions (bcquality.agent.md, feynman.agent.md) from
  authoritative templates in BCQuality. Deploys bc-mcp-bridge.js, the
  three-layer BCQuality knowledge mirror, the shared agent roster
  (~/.claude/curabis-agents/), find-altool.ps1, and the al/businesscentral
  MCP server registrations to the developer's machine (~/.claude/) — all
  machine-local, never committed to a project repository (v24: this now
  includes the roster and MCP config that used to be copied into every repo,
  see BCQuality rule roster-agents-live-on-machine-not-in-repo). Also handles
  updates to an already-configured project, including cleanup of v6-era
  repo-local mirrors and one-time migration of pre-v24 repos off the
  per-repo roster/.mcp.json/find-altool.ps1 copies. Mode C onboards a support
  user (non-developer) to the Feynman support profile: browser-only,
  read-only, no machine setup — unaffected by the v24 machine/repo split.
inputs: [repo-root]
outputs: [CLAUDE.md, .github/.agents/bcquality.agent.md, .github/.agents/feynman.agent.md, ~/.claude/bcquality-knowledge/, ~/.claude/curabis-agents/, ~/.claude/find-altool.ps1, cspell.json, projectmemory/, docs/]
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
- **"Onboard en supportbruger til CURABIS Standard"** → support profile (Mode C)

Detect which mode based on the trigger phrase and proceed accordingly.

## Source: the channel clone (BCQuality is PRIVATE — no raw URLs)

All artifacts come from the machine's **channel clone** — a git clone of
`Curabis/QualityHub` pinned to the `stable` branch. Authentication is Git
Credential Manager (the developer's existing GitHub login); there are NO
tokenless raw.githubusercontent fetches anywhere — the repo is private.

```
SRC         = %USERPROFILE%\.claude\QualityHub      (kanal-klonen, stable)
BASE        = {SRC}\custom\setup
AGENTS_BASE = {SRC}\custom\agents
```

**Before ANY Mode A/B work, ensure the channel clone is fresh:**

    git -C "$env:USERPROFILE\.claude\QualityHub" fetch origin stable --quiet
    git -C "$env:USERPROFILE\.claude\QualityHub" checkout -B stable origin/stable --quiet

If the clone is missing entirely:

    git clone --branch stable --single-branch https://github.com/Curabis/QualityHub.git "$env:USERPROFILE\.claude\QualityHub"

**Vocabulary:** wherever this document says "fetch", it means **copy the file
from SRC** — a filesystem copy, which preserves raw bytes by definition (the
old HTTP-encoding pitfalls do not exist here).

| Artefakt | Placering |
|---|---|
| bc-mcp-bridge.js | `{BASE}/bc-mcp-bridge.js` |
| bc-mcp.config.template.json | `{BASE}/machine/bc-mcp.config.template.json` |
| bcquality.agent.md | `{BASE}/templates/bcquality.agent.md` |
| immanuel.agent.md | `{AGENTS_BASE}/immanuel.agent.md` |
| carlin.agent.md | `{AGENTS_BASE}/carlin.agent.md` |
| francis.agent.md | `{AGENTS_BASE}/francis.agent.md` |
| al-triage.agent.md | `{BASE}/templates/al-triage.agent.md` |
| al-complexity.agent.md | `{BASE}/templates/al-complexity.agent.md` |
| al-review.agent.md | `{BASE}/templates/al-review.agent.md` |
| bc-mcp.agent.md | `{BASE}/templates/bc-mcp.agent.md` |
| algo-settings.agent.md | `{BASE}/templates/algo-settings.agent.md` |
| columbo.agent.md | `{AGENTS_BASE}/columbo.agent.md` |
| florence.agent.md | `{AGENTS_BASE}/florence.agent.md` |
| m365.agent.md | `{AGENTS_BASE}/m365.agent.md` |
| weber.agent.md | `{AGENTS_BASE}/weber.agent.md` |
| feynman.agent.md | `{AGENTS_BASE}/feynman.agent.md` |
| smiley.agent.md | `{AGENTS_BASE}/smiley.agent.md` |
| court.agent.md | `{AGENTS_BASE}/court.agent.md` |
| lincoln.agent.md | `{AGENTS_BASE}/lincoln.agent.md` |
| aurelius.agent.md | `{AGENTS_BASE}/aurelius.agent.md` |
| munger.agent.md | `{AGENTS_BASE}/munger.agent.md` |
| edison.agent.md | `{AGENTS_BASE}/edison.agent.md` |
| ferencz.agent.md | `{AGENTS_BASE}/ferencz.agent.md` |
| roemer.agent.md | `{AGENTS_BASE}/roemer.agent.md` |
| cspell.json | `{BASE}/templates/cspell.json` |
| find-altool.ps1 | `{BASE}/machine/find-altool.ps1` (v24: machine artifact, not a repo template) |
| feynman-onboarding.md | `{BASE}/templates/feynman-onboarding.md` |
| sync-bcquality-knowledge.ps1 | `{BASE}/sync-bcquality-knowledge.ps1` |

CLAUDE.md is generated dynamically — not fetched as a static template because
it contains project-specific paths.

**v24 — machine vs. repo split:** of the 22 agent files above, only
`bcquality.agent.md` (the marker this whole mechanism gates on) and
`feynman.agent.md` (support sessions have no `~/.claude/` to read from) are
still written into a repo's `.github/.agents/`. The remaining 20 — including
`florence.agent.md`, which goes to `~/.claude/agents/florence.md` as a real
Claude Code subagent rather than `~/.claude/curabis-agents/` — are deployed
ONCE PER MACHINE by `sync-bcquality-knowledge.ps1` to `~/.claude/curabis-agents/`
(or `~/.claude/agents/` for Florence) and referenced from the machine's own
`~/.claude/CLAUDE.md`, not from any repo's CLAUDE.md. Same script also
deploys `find-altool.ps1` to `~/.claude/find-altool.ps1` and registers the
`al` + `businesscentral` MCP servers at user scope (`claude mcp add --scope
user`) — no `.mcp.json` is written into the repo for these two standard
servers any more. See BCQuality rule `roster-agents-live-on-machine-not-in-repo`.

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
- `~/.claude/find-altool.ps1`      → AL MCP tool-finder deployed (v24: machine-global, not repo-local)
- `CLAUDE.md`                      → already configured?
- `~/.claude/bc-mcp-bridge.js`     → bridge already installed?
- `~/.bc-mcp.config.json`          → BC credentials present?

Also run `claude mcp list` (or `claude mcp get al` / `claude mcp get businesscentral`)
to check whether the two standard MCP servers are already registered at user scope.
If any of the above machine-level artifacts are missing, Step 3 will deploy them via
`sync-bcquality-knowledge.ps1` — no separate action needed here beyond noting it in
the setup report.

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

#### 3c. bcquality-knowledge, roster agents, find-altool.ps1, MCP registration (v24)

Everything machine-global beyond the bridge and BC secret — the knowledge
mirror, the 20 roster agent files (19 to `~/.claude/curabis-agents/` +
Florence to `~/.claude/agents/florence.md`), `~/.claude/find-altool.ps1`, and
the `al`/`businesscentral`/`microsoft-learn` MCP registrations — is deployed
by ONE script, `sync-bcquality-knowledge.ps1`. None of it is ever committed
to a project repository (BCQuality rule
`bcquality-knowledge-must-mirror-to-machine-not-repo`, extended in v24 to
`roster-agents-live-on-machine-not-in-repo`). Rationale: developers switch
between many repos daily — N per-repo copies are permanently out of sync
with each other, while one machine copy needs exactly one sync per upstream
change.

1. Fetch `{BASE}/sync-bcquality-knowledge.ps1` → write AS RAW BYTES
   (`Invoke-WebRequest -OutFile`, never via string content — re-encoding
   corrupts UTF-8) to `~/.claude/sync-bcquality-knowledge.ps1`
2. Run it once:
   `powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\sync-bcquality-knowledge.ps1"`
   This populates:
   - `~/.claude/bcquality-knowledge/{custom,community,microsoft}/` + `INDEX.md`
     (domain + keywords per file, for relevance-based lookup — `custom/` is
     always read in full, `community/` and `microsoft/` are scanned via the
     index rather than preloaded, since together they run into the hundreds
     of files)
   - `~/.claude/curabis-agents/*.agent.md` (19 files)
   - `~/.claude/agents/florence.md` (Florence, as a real subagent)
   - `~/.claude/find-altool.ps1`
   - `al` + `businesscentral` + `microsoft-learn` registered at user MCP scope
     (idempotent — a server that already exists is reported, not re-added or
     overwritten). `microsoft-learn` is `https://learn.microsoft.com/api/mcp`,
     HTTP transport, no auth — the same official documentation search Mode C
     already gives support users; v24 closes the gap where developers had
     only the static `microsoft/` knowledge-file snapshot and no live search
     of Microsoft's own docs.
3. If a v6-era `.github/.agents/bcquality-knowledge/` exists in THIS repo,
   add it to `.gitignore` so no future session can accidentally commit it
   (see the v6-cleanup step in Mode B for full removal — this step just
   prevents new commits).
4. Confirm: "Maskine-opsætning synkroniseret — bcquality-knowledge [antal]
   filer, curabis-agents 19 filer, Florence, find-altool.ps1, MCP (al,
   businesscentral, microsoft-learn)."

This machine setup is what the global `~/.claude/CLAUDE.md` roster section
and the project CLAUDE.md's session-start line both depend on. Without this
step, those references point at artifacts that don't exist yet on a fresh
machine.

### Step 4 — Write project files

#### 4a. CLAUDE.md

**v24 change:** most of what used to be duplicated into every repo's CLAUDE.md
(Smiley, Carlin, on-demand roster, Francis, projectmemory/docs read
instructions) now lives ONCE in the developer's own `~/.claude/CLAUDE.md`
(see `machine/CLAUDE.md`'s "CURABIS Standard — Shared Roster" section),
gated on this repo having `.github/.agents/bcquality.agent.md` — the same
marker file/gate the existing "Auto-update BCQuality" section already used.
The project CLAUDE.md shrinks to what is genuinely repo state OR must work
before any global file exists: project name, AL app layout, the machine
self-heal bootstrap (kept — see why below), the Feynman support-session
trigger (kept — support sessions have no `~/.claude/` to read the global
file from either), and the project footer.

**Why self-heal stays repo-local (do NOT move it to global):** self-heal's
entire job is bootstrapping `~/.claude/CLAUDE.md` on a machine that doesn't
have it yet — a developer cloning an already-configured repo for the first
time on a fresh machine has nothing BUT this repo's CLAUDE.md to read. If
self-heal itself lived only in the global file, there would be no way to
reach it on that fresh machine. This is the mirror image of why Feynman
stays repo-local (his audience never gets a global file; self-heal's job IS
installing one) — both are genuine exceptions to the v24 move, for opposite
reasons.

Generate from this template, substituting answers from Step 2:

```markdown
# {PROJECT_NAME} — Claude Code Instructions

This file is read automatically by Claude Code at the start of every
session, together with the developer's `~/.claude/CLAUDE.md` (once it
exists — see self-heal below for a fresh machine). This repo has
`.github/.agents/bcquality.agent.md`, so once the global file exists, its
"CURABIS Standard — Shared Roster" section applies for the whole session:
BCQuality knowledge, Smiley, Carlin, the on-demand agent roster, Francis,
and the projectmemory/docs read instructions. That content is not
duplicated here — see `~/.claude/CLAUDE.md` on the developer's machine for
the full text.

## BCQuality — machine self-heal

**Trigger** if EITHER (a) this machine is not CURABIS-onboarded —
`~/.claude/CLAUDE.md` or `~/.claude/bc-mcp-bridge.js` is missing — OR (b) the
machine is STALE: `~/.claude/CLAUDE.md` still references
`raw.githubusercontent.com` or the legacy `Curabis/BCQuality` repo (a
machine that slept through a consumption migration — vacation, leave, spare
laptop). Run the onboarding NOW (idempotent; identity from git config; the
first git contact may open a browser login — that IS the authentication):

    git clone --branch stable --single-branch https://github.com/Curabis/QualityHub.git "$env:USERPROFILE\.claude\QualityHub"
    powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\QualityHub\custom\setup\machine\Install-CurabisMachine.ps1"

(Skip the clone line if `%USERPROFILE%\.claude\QualityHub` already exists.)
This installs `~/.claude/CLAUDE.md` (never overwriting an existing one),
`~/.claude/bc-mcp-bridge.js`, `~/.bc-mcp.config.json` (template), and runs
`sync-bcquality-knowledge.ps1` — which also deploys the roster agents,
Florence, `find-altool.ps1`, and the `al`/`businesscentral` MCP
registrations (see Step 3c in Mode A). In the STALE case, additionally
refresh the machine's `~/.claude/CLAUDE.md` CURABIS sections from
`%USERPROFILE%\.claude\QualityHub\custom\setup\machine\CLAUDE.md` — show the
diff, preserve the Identity section and any personal sections verbatim, and
ask for confirmation (it is the developer's personal file). Report the
manual leftovers (personal client secret; the AL Language extension if VS
Code lacks it) and ask the developer to restart Claude Code.

If only `~/.claude/bcquality-knowledge/` (or the roster/find-altool.ps1/MCP
registrations) is missing or stale, the lighter self-heal suffices:

    powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\sync-bcquality-knowledge.ps1"

This section stays repo-local — see the note above.

## Feynman — Support-sessioner

Hvis sessionens første besked starter med **"Feynman:"** — eller brugeren
identificerer sig som support/forretningskonsulent (ikke-udvikler):

1. Læs `.github/.agents/feynman.agent.md` og arbejd efter hans protokol
   resten af sessionen.
2. Spring over: BCQuality machine self-heal, AL MCP, BC MCP og test-afvikling.
   Support-miljøet er browserbaseret (claude.ai / Claude Code på web) — der er
   ingen lokal maskine at onboarde, og det er meningen.
3. Strengt læsende: ingen redigering, ingen commits, ingen builds.

Denne sektion har forrang over BCQuality-sektionens self-heal — og den bliver
bevidst stående HER, repo-lokalt, uanset v24-flytningen ovenfor: en
supportbruger har intet `~/.claude/CLAUDE.md` at læse den globale roster-
sektion fra, så Feynman-trigger'en skal være synlig i selve repoet.

## AL projects

{AL_PROJECTS_SECTION}

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

#### 4b. AL MCP + businesscentral MCP (v24: machine-registered, no repo .mcp.json)

**v24 change:** both standard MCP servers now live entirely on the
developer's machine — registered once via `claude mcp add --scope user`,
never committed as `.mcp.json` in the repo. This eliminates the entire class
of "hardcoded developer path in a git-committed file" bugs, since there is
now exactly one place per machine to get it right, not one per repo.

Nothing to write here in Step 4 — Step 3c (above) already handled
registration as part of the machine deploy, and it is idempotent (safe to
run again on an already-onboarded machine).

If a repo ever needs an ADDITIONAL MCP server beyond these two standard
ones (repo- or customer-specific), create `.mcp.json` for just that entry —
never re-add `al` or `businesscentral` to it; they would shadow the
user-scope registration with a project-scope duplicate approval prompt for
no benefit.

The only machine prerequisite for the `al` server is the AL Language
extension itself (`ms-dynamics-smb.al` from the Marketplace, recent version)
— `find-altool.ps1` locates its `altool.exe` dynamically and reports clearly
if it is missing.

#### 4c. .github/.agents/ (fetch from BCQuality — v24: two files, not twenty-one)

Fetch and write verbatim:
- `{BASE}/templates/bcquality.agent.md` → `.github/.agents/bcquality.agent.md`
- `{AGENTS_BASE}/feynman.agent.md`      → `.github/.agents/feynman.agent.md`

Create `.github/.agents/` if it does not exist.

These are the only two agent files that belong in a repo. `bcquality.agent.md`
is the marker file the machine's `~/.claude/CLAUDE.md` gates the whole
"CURABIS Standard — Shared Roster" section on; `feynman.agent.md` must stay
repo-local because Mode C support sessions have no `~/.claude/` to read a
global roster from. Every other roster agent (Smiley, Carlin, Immanuel,
Francis, Columbo, Florence, the Court, Rømer, Weber, Ferencz, Edison,
al-triage, al-complexity, al-review, bc-mcp, algo-settings) is deployed machine-globally
by Step 3c and referenced from `~/.claude/CLAUDE.md` — see BCQuality rule
`roster-agents-live-on-machine-not-in-repo`.

#### 4c-2. bcquality-knowledge, roster agents, MCP — see Step 3c

Already handled by Step 3c above (it runs before project files are written,
since 4a's CLAUDE.md and 4c's bcquality.agent.md both assume the machine
side is in place). Nothing further to do here.

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

- CLAUDE.md (slank, peger på ~/.claude/CLAUDE.md for delte regler)
- .github/.agents/bcquality.agent.md + feynman.agent.md (repo-lokale undtagelser)
- cspell.json
- HEARTBEAT.md — Florence's vagtliste
- projectmemory/ — delt projekthukommelse
- docs/specs/, docs/decisions/, docs/cleanup/ — projektdokumentation

(Resten af rosteret, find-altool.ps1 og MCP-registrering er maskin-globalt —
intet at committe for dem, se Step 3c.)

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

---

## MODE B — Update (existing project)

Triggered by: "Opdater CURABIS Standard fra BCQuality"

**Step 0 — freshen the channel clone** (see Source section): fetch + checkout
`origin/stable` in `%USERPROFILE%\.claude\QualityHub`; create the clone if
missing. Every copy below reads from that clone.

Updates only the files that come directly from BCQuality.
Never touches `CLAUDE.md`'s project-specific content, `projectmemory/`, `docs/`, or `~/.bc-mcp.config.json`.

**v24 note:** as of v24 this table is much shorter than it used to be — 19 of
the 21 agent files, `.mcp.json`'s standard entries, and `find-altool.ps1` are
no longer repo artifacts at all; they are machine-global (see the
machine-level table below, and Step 3c in Mode A for what deploys them).
Repos still on v23 or earlier need the one-time migration below before this
shorter table applies to them.

### What gets updated — repo-level

| Fil | Handling |
|---|---|
| `.github/.agents/bcquality.agent.md` | Fetch fresh from BCQuality, overwrite |
| `.github/.agents/feynman.agent.md` | Fetch fresh from BCQuality, overwrite (add if missing) |
| `cspell.json` — words from template | Merge new words, keep project words |
| `.apps/*.code-workspace` — reference layout | Create/complete: app projects + `.AL-Go` + relative `../docs` (rule `al-development-must-use-apps-workspace`) |
| Alle øvrige `*.code-workspace` (inkl. rodens `al.code-workspace`) | Delete — kun ét workspace pr. repo; rapportér de slettede |
| `HEARTBEAT.md` | Create from template if missing (substitute tokens), never overwrite — but run the staleness check below on every Mode B pass |
| `docs/specs/`, `docs/decisions/`, `docs/cleanup/` | Create if missing, never overwrite content |

### What gets updated — machine-level (once per machine, not per repo)

Run every time Mode B runs, regardless of which repo it was triggered from —
these are shared across every CURABIS repo on the machine:

| Artefakt | Handling |
|---|---|
| `~/.claude/bc-mcp-bridge.js` | Fetch fresh from BCQuality, overwrite |
| `~/.claude/sync-bcquality-knowledge.ps1` | Fetch fresh from BCQuality (raw bytes), overwrite (add if missing) |
| `~/.claude/bcquality-knowledge/` | Re-run the sync script (see below) |
| `~/.claude/curabis-agents/*.agent.md` (19 files) | Re-run the sync script |
| `~/.claude/agents/florence.md` | Re-run the sync script |
| `~/.claude/find-altool.ps1` | Re-run the sync script |
| `al` + `businesscentral` + `microsoft-learn` MCP servers (user scope) | Re-run the sync script — idempotent: registers if missing, does NOT touch an existing registration (a developer's personal-scope config is not policed the way repo-shared `.mcp.json` used to be) |
| `.github/.agents/bcquality-knowledge/` + `.github/.agents/sync-bcquality-knowledge.ps1` | v6-era repo-local mirror: propose removal (see below) |

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
   - ANY remaining `raw.githubusercontent.com`-based self-heal or onboarding
     command (v15-v18 era) — the repo is private; raw URLs are dead. The
     current form is git-based via the channel clone.
   If any match, propose replacing the section with the current template from
   Step 4a and ask for confirmation before editing CLAUDE.md (same confirmation
   gate as the agent-synligheds-check below).

### Machine CLAUDE.md refresh (Mode B)

The developer's global `~/.claude/CLAUDE.md` carries the CURABIS auto-update
instructions. After a consumption-model change (like v19's git migration, or
v24's move of the roster/on-demand-agents/Smiley/Carlin/Francis sections
from every repo's CLAUDE.md into this file), those instructions go stale on
every already-onboarded machine. Compare the machine file's CURABIS sections
against `{BASE}/machine/CLAUDE.md` in the channel clone. If they diverge
structurally (e.g. still reference raw URLs or GitHub-API SHA checks, or are
missing the v24 "CURABIS Standard — Shared Roster" section entirely),
propose the update — show the diff, preserve the Identity section verbatim,
and ask for confirmation before editing: it is the developer's personal file.

### v23 → v24 migration (existing repos, one-time per repo)

v24 moved 19 agent files, `.mcp.json`'s two standard entries, and
`find-altool.ps1` from repo-local to machine-global (see the Source section's
"machine vs. repo split" note). A repo configured under v23 or earlier still
has the old repo-local copies. Detect and migrate — always confirm before
removing anything, same gate as the v6-era cleanup above:

**1. Extra `.github/.agents/*.agent.md` files**

List `.github/.agents/*.agent.md`. Anything other than `bcquality.agent.md`
and `feynman.agent.md` is a pre-v24 repo-local copy of a now-machine-global
agent. Before proposing removal, confirm Step 3c has run on THIS machine in
THIS Mode B pass (it always does, earlier in this flow) — that guarantees
the roster is available globally before the repo-local copies disappear.

```
⚠️ v24-migrering: dette repo har [N] agent-filer i .github/.agents/ som nu er
maskin-globale (~/.claude/curabis-agents/ + ~/.claude/agents/florence.md).
Maskinen her har allerede den globale roster (bekræftet i dette Mode B-kald).
Må jeg fjerne de [N] repo-lokale kopier? (ja/nej)

  - immanuel.agent.md, francis.agent.md, columbo.agent.md, ... [list them]
```

On yes: `git rm` each file not in `{bcquality.agent.md, feynman.agent.md}`.

**2. Old-style CLAUDE.md (inline generic sections)**

Check for any of these headings still present verbatim in the project
CLAUDE.md: `## Smiley — Session Watchdog`, `## Carlin — Bullshit Detector`,
`## On-demand agents`, `## Francis — proaktiv regelobservation`,
`## Shared project memory`, `## Project documentation`. Their presence means
this repo predates v24. Propose REMOVING only those headings/sections and
replacing them with the short pointer paragraph from Step 4a. Do NOT touch
`## BCQuality` (the self-heal section) or `## Feynman — Support-sessioner` —
both stay, unchanged, in every version. Preserve everything project-specific
(project name, AL_PROJECTS_SECTION, running-tests, about-this-project)
verbatim. Show the diff and ask for confirmation before editing (same gate
as the v6-era obsolete-forms check above).

**3. `.mcp.json` — standard entries (multi-developer coordination required)**

This is the one migration step that is NOT safe to do unilaterally from a
single Mode B run, because `.mcp.json` is git-committed and shared: removing
it assumes EVERY developer working on this repo has already run Step 3c on
their OWN machine. Doing this before that is true silently breaks AL/BC MCP
for anyone who pulls the change and hasn't migrated yet.

If `.mcp.json` contains the standard `al` and/or `businesscentral` entries:

```
⚠️ .mcp.json indeholder de to standard MCP-servere (al, businesscentral), som
i v24 er maskin-globale i stedet. At fjerne dem fra .mcp.json er kun sikkert
naar ALLE udviklere paa dette repo har koert maskin-opsaetningen (Step 3c) paa
egen maskine - ellers mister de AL/BC MCP naar de henter aendringen.

Har alle udviklere paa dette repo allerede migreret deres maskine? (ja/nej)
Hvis usikker: svar nej - .mcp.json kan blive staaende uden problemer, det er
kun en smule duplikeret konfiguration, ikke en fejltilstand.
```

Only remove the two entries (never the whole file — a repo may have
legitimate additional MCP servers) if the developer explicitly confirms yes.
If the file becomes empty afterward (`{"mcpServers": {}}`), propose deleting
`.mcp.json` entirely in the same confirmation.

**4. `.vscode/find-altool.ps1`**

If present, propose removal — it is superseded by `~/.claude/find-altool.ps1`
(machine-global, cwd-walkup discovery, no repo dependency). Safe to remove
independently of the `.mcp.json` migration above, since removing the *file*
doesn't affect any `.mcp.json` entry that still references the old
repo-relative walk-up form until that entry itself is migrated per step 3.

### HEARTBEAT.md token substitution (Mode B)

When creating HEARTBEAT.md from template in Mode B:

1. Derive `{PROJECT_NAME}` — read the first `# ` heading from `CLAUDE.md`
   (e.g. `# ProjectManagement — Claude Code Instructions` → `ProjectManagement`).
   If CLAUDE.md has no heading, use the git remote repo name.
2. Set `{SETUP_DATE}` to today's ISO date (YYYY-MM-DD)
3. Substitute both tokens before writing the file

### HEARTBEAT.md staleness check (Mode B)

`HEARTBEAT.md` is "never overwrite" (Step 4f / the reconciliation table above) — that
protects legitimate developer customization and the "Sidst opdateret" line, but it must
not mean drift goes undetected forever (BCQuality rule
`mode-b-never-overwrite-files-still-need-staleness-checks`). If `HEARTBEAT.md` already
exists, check it for known-bad patterns:

- **`Curabis/BCQuality` referenced anywhere** (PR checks, API URLs — e.g.
  `https://api.github.com/repos/Curabis/BCQuality/pulls?state=open`). That repository is
  the abandoned public fork of `microsoft/BCQuality` — Florence will silently report
  "Routine: no open PRs" against it forever, since no one opens PRs there. The correct
  target is `Curabis/QualityHub`.

If a match is found, show the specific line(s) and the proposed corrected line(s), and
ask for confirmation before editing — same confirmation gate as the CLAUDE.md
obsolete-forms check above. Never silently rewrite the whole file; this is a targeted
line fix that leaves everything else (custom checklist items, the "Sidst opdateret" date,
any team-added stations) untouched.

### What does NOT get updated

- `CLAUDE.md`'s project-specific content (project name, AL_PROJECTS_SECTION,
  running-tests, Feynman section, about-this-project) — managed per project,
  never auto-overwritten. Its now-removed generic sections (Smiley, Carlin,
  on-demand roster, Francis, projectmemory/docs instructions) are only
  touched once, during the v23→v24 migration above, and only with confirmation.
- `projectmemory/` — team knowledge, never overwritten by tooling
- `docs/` content — project documentation, never overwritten by tooling
- `~/.bc-mcp.config.json` — contains developer secrets
- An existing `al`/`businesscentral` user-scope MCP registration — Step 3c
  registers if missing but never corrects an existing one (see the
  machine-level table above)

### After update — lokal-agent-check (RegelSanity)

The reconciliation and validation steps in this Mode B flow constitute
**Rømer's inspection round** (`roemer.agent.md` owns the complete station
list). Reconciliation runs in BOTH directions. Missing template files are
handled above — this check finds the opposite: **extra** files in
`.github/.agents/` that are not in this document's template table (see
BCQuality rule `repo-local-agents-must-be-universalized-or-removed`).

**v24 note:** the template table now has exactly two rows (`bcquality.agent.md`,
`feynman.agent.md`), so on a v24 repo this check simply means "nothing else
should ever appear in `.github/.agents/`." A repo still full of pre-v24
copies isn't a RegelSanity violation — it is v23-era state, handled by the
one-time migration above (step 1), which runs first. This check is what
catches NEW extra files going forward (e.g. someone manually drops a custom
agent into `.github/.agents/` after migration) — same universalize-or-remove
choice as before.

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

### After update — agent-synligheds-check (v24: machine-level, not repo-level)

**v24 change:** the on-demand roster and the always-active Smiley/Carlin
sections moved to `~/.claude/CLAUDE.md` (see "CURABIS Standard — Shared
Roster" in `machine/CLAUDE.md`), so this check no longer compares against
the PROJECT CLAUDE.md — there is nothing left there to reconcile (the
project CLAUDE.md has no on-demand list any more; Feynman has his own
dedicated section and needs no separate visibility check). The check itself
still matters, just one level up: compare `~/.claude/curabis-agents/*.agent.md`
+ `~/.claude/agents/florence.md` against the roster list inside
`~/.claude/CLAUDE.md`.

**Special case — Smiley:** `smiley.agent.md` is always-active, not on-demand.
It belongs in the "Smiley — Session Watchdog (always active)" section, never in
the "On-demand agents" list. If Smiley is missing, propose his own section —
not an on-demand entry.

In practice this check is subsumed by "Machine CLAUDE.md refresh (Mode B)"
above: that step already diffs the developer's `~/.claude/CLAUDE.md`
structurally against `{BASE}/machine/CLAUDE.md` and proposes the update
(with confirmation) whenever they diverge — a newly-shipped roster agent not
yet listed is exactly the kind of structural divergence that step catches.
No separate action needed here beyond running that step.

### After update — report and commit

Report what changed, then ask:
> "Opdatering færdig. Vil du have mig til at committe ændringerne? (ja/nej)"

If yes, commit:
```
[SETUP] Opdater CURABIS Standard fra BCQuality

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

---

## MODE C — Support-profil (onboard en supportbruger)

Triggered by: **"Onboard en supportbruger til CURABIS Standard"**
(også accepteret: "Konfigurer support-profil")

Formål: give en ikke-udvikler (forretningskonsulent, supportmedarbejder)
mulighed for at stille spørgsmål til CURABIS-repos og Microsofts kilder —
via Feynman-agenten (`feynman.agent.md`), uden VS Code, uden lokal
maskinopsætning og uden skriveadgang.

### Hvad profilen IKKE indeholder — med vilje

- Ingen VS Code, ingen AL Language extension
- Ingen bc-mcp-bridge, ingen `~/.bc-mcp.config.json` — supportbrugeren får
  aldrig secrets
- Ingen QualityHub-klon og ingen machine self-heal — supportbrugeren har ikke
  (og skal ikke have) adgang til QualityHub; `feynman.agent.md` ligger i hvert
  konfigureret repo, og CLAUDE.md-templatens "Feynman — Support-sessioner"-
  sektion slår self-heal fra i support-mode
- Ingen skriveadgang til noget repo — rollen er læsende, og GitHub-rollen
  håndhæver det

### Step 1 — Spørg om to ting

```
1. Supportbrugerens navn og GitHub-brugernavn?
2. Hvilke repos skal brugeren have læseadgang til?
```

### Step 2 — GitHub-adgang (udføres af administratoren)

Guide administratoren gennem:

1. Invitér brugeren til organisationen som **member**
2. Giv **Read**-rolle på de valgte repos — aldrig Write/Maintain/Admin
3. Verificér at brugeren IKKE har adgang til `Curabis/QualityHub`

### Step 3 — Claude-miljø (browser, ikke VS Code)

1. Claude-sæde til brugeren (Team-plan)
2. **Claude Code på web** (claude.ai/code): forbind brugerens GitHub-konto og
   vælg de tildelte repos
3. MCP-connectors i brugerens miljø — begge læsende, ingen tokens med
   skrive-scopes:
   - **GitHub MCP** — adgang til Microsofts offentlige repos:
     `microsoft/BCApps`, `microsoft/ALAppExtensions`,
     `MicrosoftDocs/dynamics365smb-docs`
   - **Microsoft Learn MCP** — officiel dokumentationssøgning

### Step 4 — Onboarding-dokument

1. Fetch `{BASE}/templates/feynman-onboarding.md`
2. Erstat `{SUPPORT_NAME}`, `{REPO_LIST}` (punktliste over de tildelte repos)
   og `{SETUP_DATE}` (dags dato, ISO)
3. Aflevér dokumentet til supportbrugeren (mail/Teams) — det forklarer
   trigger-frasen "Feynman:", gode spørgsmål, og hvordan et Feynman-notat
   videresendes til en udvikler

### Step 5 — Verifikation

Bed supportbrugeren starte en session i et af de tildelte repos med:

> "Feynman: hvad kan du hjælpe mig med i dette projekt?"

Forventet: svar på dansk i forretningssprog, bekræftelse af support-mode
(strengt læsende), og INGEN self-heal-/onboarding-støj ved session-start.

### Forudsætning

Mode C forudsætter at de tildelte repos er konfigureret med CURABIS Standard
v23+ (Feynman i rosteret + support-sektionen i CLAUDE.md). Kør Mode B på
repos, der endnu ikke har `feynman.agent.md`.

---

## Invocation note

This agent is read on demand from the machine's channel clone
(`%USERPROFILE%\.claude\QualityHub\custom\setup\curabis-standard.agent.md`,
after freshening — see Source section). All three commands work in any project —
including one not yet configured — because the machine's `~/.claude/CLAUDE.md`
(installed by onboarding) knows the clone location. On a machine without the
clone, the two-line onboarding in Step 4a's self-heal is the entry point.