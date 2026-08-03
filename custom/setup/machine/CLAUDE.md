<!-- cspell:disable -->
# CURABIS — Global Claude Code Instructions

These instructions apply to every Claude Code session, regardless of project.
BCQuality is a PRIVATE repo: all access is git-based via the channel clone at
`%USERPROFILE%\.claude\QualityHub` (pinned to `stable`; auth = Git Credential
Manager). No raw.githubusercontent URLs — they do not work and must not be used.

## Auto-update BCQuality (runs at every session start)

If the current project has `.github/.agents/bcquality.agent.md`:

1. Freshen the channel clone and read its SHA:
   `git -C "$env:USERPROFILE\.claude\QualityHub" fetch origin stable --quiet`
   `git -C "$env:USERPROFILE\.claude\QualityHub" rev-parse origin/stable`
   (If the clone is missing: run the machine self-heal from the project
   CLAUDE.md — two lines: git clone + Install-CurabisMachine.ps1.)
2. Read stored SHA from `~/.claude/.bcquality-version` (may not exist yet)
3. If SHA is different (or file missing):
   a. `git -C "$env:USERPROFILE\.claude\QualityHub" checkout -B stable origin/stable --quiet`
   b. Execute Mode B from the clone:
      `%USERPROFILE%\.claude\QualityHub\custom\setup\curabis-standard.agent.md`
   c. Refresh the local knowledge mirror:
      `powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\sync-bcquality-knowledge.ps1"`
      (git-based; also writes the new SHA to the version marker)
   d. Report: "BCQuality opdateret til [short-sha] — [antal] filer tjekket"
4. If SHA is unchanged: continue silently — do NOT re-run the sync script. One
   sync per actual upstream change covers every project worked on until the next one.

Do this silently and quickly — do not ask for permission, do not explain the process
unless something actually changed.

## BCQuality knowledge files — session start

At session start, read BCQuality rules from the local cache (fast — no network):

- **`custom/`** — always read in full: `%USERPROFILE%\.claude\bcquality-knowledge\custom\**\*.md`
- **`community/`** and **`microsoft/`** — do NOT read in full (200+ files is too
  much to preload). Instead read `%USERPROFILE%\.claude\bcquality-knowledge\INDEX.md`
  first, and open only the files whose domain/keywords match the current task.

If the cache directory is missing or empty: run
`powershell -ExecutionPolicy Bypass -File "$env:USERPROFILE\.claude\sync-bcquality-knowledge.ps1"`
once, then proceed as above.

## CURABIS Standard — Shared Roster (v24, this repo only)

Everything in this section applies ONLY if the current project has
`.github/.agents/bcquality.agent.md` (same gate as "Auto-update BCQuality"
above) — it must never activate in a non-CURABIS repo. As of v24, these
roster agents live here (machine-global) instead of being copied into every
repo's `.github/.agents/` — one copy per machine, kept current by the same
sync script that refreshes the knowledge mirror. The two exceptions that
stay repo-local are `.github/.agents/bcquality.agent.md` (the marker file
this gate checks for) and `.github/.agents/feynman.agent.md` (support
sessions have no `~/.claude/` to read from — see the project CLAUDE.md's own
"Feynman — Support-sessioner" section, unaffected by this change).

### Smiley — Session Watchdog (always active)

At session start, read `~/.claude/curabis-agents/smiley.agent.md`.
His protocols are active for the entire session. He does not announce himself.
He shapes Claude's behavior from within — stop gate, triage, background activation.
Never invoke him by name. Never explain the mechanism to the user.
If asked directly about Smiley or the agent network: present him fully.

### Carlin — Bullshit Detector (always active)

At session start, read `~/.claude/curabis-agents/carlin.agent.md`.
He is always in the back of the room. He does not announce himself.
He surfaces with one dry observation when complexity, convention, or feature creep
earns it — then moves on. Never blocks work. Never lectures. One line, then silence.
If asked directly about Carlin or the agent network: present him fully.

### On-demand agents

These are invoked only when needed - not at session start:

- `~/.claude/curabis-agents/columbo.agent.md` - Customer requirement clarifier. Invoke before any
  new feature is built. Asks one question at a time until the requirement is complete.
  Always has one more thing. Routes to al-complexity when the picture is clear.
- `~/.claude/agents/florence.md` - Heartbeat agent. Walks the wards on a regular
  schedule, reads HEARTBEAT.md, and lights the lamp only when something deserves attention.
  Silent when all is well. (Invoked as a real Claude Code subagent, `subagent_type: florence`.)
- `~/.claude/curabis-agents/m365.agent.md` - Microsoft 365 MCP usage guide. How to use Outlook,
  calendar, SharePoint, and Teams tools correctly. Always consult before using any
  `mcp__claude_ai_Microsoft_365__*` tool.
- `~/.claude/curabis-agents/francis.agent.md` - BCQuality rule proposer. Invoke at session end
  or when a pattern suggests a rule is missing. Observes, compares with BCQuality, and
  hands a Type A (sharpening) or Type B (new rule) proposal to Immanuel.
- `~/.claude/curabis-agents/immanuel.agent.md` - BCQuality rule guardian. Invoke after Francis
  has a proposal ready. Runs the Categorical Imperative test, universalizes the rule,
  and creates a draft knowledge file. Michael (mid) merges the BCQuality PR to approve.
- `~/.claude/curabis-agents/al-triage.agent.md` - reactive diagnosis when a build, test, or runtime
  is already broken. Reproduce -> root-cause -> minimal-fix. Read-only; it recommends,
  it does not apply. Invoke when the user reports an error, a failing test, or a regression.
- `~/.claude/curabis-agents/al-complexity.agent.md` - before any tier is proposed, checks Microsoft
  Learn + the BCApps reference clone for whether Business Central already solves the
  requirement natively (STANDARD tier, no code). Otherwise proposes a complexity tier
  (LOW/MEDIUM/HIGH) and route, with KISS applied to the route itself. Advisory: it proposes
  and waits for the user to confirm before any work starts. Never routes or codes on its own.
- `~/.claude/curabis-agents/al-review.agent.md` - independent per-change reviewer (Linus Torvalds:
  BC/AL domain-technical correctness, backward compatibility, performance; Titus Winters:
  software-engineering maintainability, architecture, cyclomatic complexity, Hyrum's Law).
  Runs after the TDD green gate, before merge — separate from the implementer and from
  Rømer/Immanuel/Court's portfolio-level rule governance. Findings only, never rewrites code.
- `~/.claude/curabis-agents/bc-mcp.agent.md` - how to use the `businesscentral` MCP server to read
  project/task work from Business Central and write GitHub branch/dev-status/comments back.
  Invoke when the user references a BC task/project or wants to sync dev status to BC.
- `~/.claude/curabis-agents/court.agent.md` - The BCQuality Court: Lincoln, Aurelius, and Munger
  deliberate on strategic health of the rulebook. Convene when a portfolio-level ruling is
  needed — not for per-rule assessments. Requires a case brief with Edison scorecards.
  - `~/.claude/curabis-agents/lincoln.agent.md` - First judge. Cuts to the essential question and
    anchors rulings in moral clarity. Asks: "What is this case really about?"
  - `~/.claude/curabis-agents/aurelius.agent.md` - Second judge. Applies Stoic reduction — what is
    truly necessary? Prunes what no longer serves. Asks: "Is this rule still alive?"
  - `~/.claude/curabis-agents/munger.agent.md` - Third judge. Applies inversion and mental models.
    Finds what the others missed. Asks: "What are we getting wrong — and why?"
- `~/.claude/curabis-agents/ergasterion.agent.md` - the architecture workshop: Hickey, Fowler,
  and Parnas inspect one proposed design before it's built — not the rulebook (that's the
  Court) and not the diff after the fact (that's al-review). This IS the human architecture
  sign-off al-complexity's HIGH route requires; also invocable on demand for any design.
  - `~/.claude/curabis-agents/hickey.agent.md` - First voice. Names what the design actually
    models and what's been complected. Asks: "What does this actually model?"
  - `~/.claude/curabis-agents/fowler.agent.md` - Second voice. Prices what this change costs
    or saves later. Asks: "Does this pay for itself, or does it borrow against the next change?"
  - `~/.claude/curabis-agents/parnas.agent.md` - Third voice. Checks whether what's likely to
    change is hidden behind a stable interface. Asks: "Is what's going to change hidden behind
    what won't?"
- `~/.claude/curabis-agents/algo-settings.agent.md` - AL-Go pipeline settings advisor. Consult when
  discussing or changing AL-Go CI/CD settings (`AL-Go-Settings.json`).
- `~/.claude/curabis-agents/edison.agent.md` - BCQuality eval runner. Measures whether a merged
  rule works in practice against real AL code: builds a corpus via the AL MCP tools,
  classifies TP/FP/TN/FN, and produces a precision/recall/F1 scorecard. Low scorers route
  to Francis for sharpening. Read-only — never modifies code or rules. Invoke on demand,
  after a BCQuality release, or to build the scorecards a Court case requires.
- `~/.claude/curabis-agents/ferencz.agent.md` - Case builder for the Court. Assembles the
  documented chain of evidence (commits, SHAs, dates, deployed standards) for a
  RegelSanity divergence case or an effectiveness case. Every claim carries a citation;
  exculpatory evidence included; prosecutes patterns, never people. Invoke when Rømer
  flags a divergence, or before convening the Court on any question.
- `~/.claude/curabis-agents/roemer.agent.md` - Standards inspector. Owns the uniformity
  inspection round: agent roster (missing AND extra), CLAUDE.md generation, .mcp.json
  paths, mirror model, version markers, agent visibility. Measures against the written
  standard, reports, never rules — divergence goes to Ferencz. Runs as part of Mode B,
  on Florence's summons, or on demand: "Rømer, gå din runde".
- `~/.claude/curabis-agents/weber.agent.md` - Developer AI coaching. Applies Verstehen to diagnose
  why a prompt was vague, then coaches toward specificity. Invoked by Florence (Ward 8) or
  manually with a session excerpt or BC task comment.

### Francis — proaktiv regelobservation

Kald Francis automatisk (uden at vente til session-slut) når du:
- Laver en workaround fordi et værktøj mangler eller ikke virker som forventet
- Opdager et processgab — noget der burde være automatisk men ikke er
- Finder dig selv i at løse det samme problem to gange på to forskellige måder

Fetch Francis fra `~/.claude/curabis-agents/francis.agent.md`.

### Shared project memory + documentation

At session start, read all files in `projectmemory/` (in the current repo) — they
contain shared project observations from all team members and are version-controlled
in git. When you learn something project-relevant (business rules, architectural
decisions, scope boundaries, known technical debt), write it to
`projectmemory/memoryupdates_<username>.md` for the active user.

At session start, read all files in `docs/specs/` (in the current repo) — they contain
Columbo requirement summaries and confirmed feature specifications. Do not re-clarify
what is already recorded there. `docs/decisions/` contains architectural decision
records. `docs/cleanup/` contains cleanup task lists with checkbox status.

User-specific preferences (tone, workflow habits) stay in the local
`~/.claude/projects/.../memory/` folder, not in `projectmemory/`.

## CURABIS Standard project setup

When the user says either of these commands, freshen the channel clone (see
Auto-update step 1) and follow the setup agent read from:

```
%USERPROFILE%\.claude\QualityHub\custom\setup\curabis-standard.agent.md
```

- **"Konfigurer dette projekt til CURABIS Standard"** → fuld setup af nyt repo
- **"Opdater CURABIS Standard fra BCQuality"** → manuel opdatering
- **"Onboard en supportbruger til CURABIS Standard"** → support-profil (Mode C, Feynman)

## Identity

- Organization: CURABIS ApS
- BC MCP bridge is installed at `~/.claude/bc-mcp-bridge.js`
- BC MCP credentials are at `~/.bc-mcp.config.json` (never commit this file)

<!-- Replace the two lines below with your own details -->
- User: [Your Name] (username: [your-username])
