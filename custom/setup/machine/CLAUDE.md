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

## CURABIS Standard project setup

When the user says either of these commands, freshen the channel clone (see
Auto-update step 1) and follow the setup agent read from:

```
%USERPROFILE%\.claude\QualityHub\custom\setup\curabis-standard.agent.md
```

- **"Konfigurer dette projekt til CURABIS Standard"** → fuld setup af nyt repo
- **"Opdater CURABIS Standard fra BCQuality"** → manuel opdatering

## Identity

- Organization: CURABIS ApS
- BC MCP bridge is installed at `~/.claude/bc-mcp-bridge.js`
- BC MCP credentials are at `~/.bc-mcp.config.json` (never commit this file)

<!-- Replace the two lines below with your own details -->
- User: [Your Name] (username: [your-username])
