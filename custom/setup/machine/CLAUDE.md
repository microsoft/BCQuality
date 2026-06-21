<!-- cspell:disable -->
# CURABIS — Global Claude Code Instructions

These instructions apply to every Claude Code session, regardless of project.

## Auto-update BCQuality (runs at every session start)

If the current project has `.github/.agents/bcquality.agent.md`:

1. Fetch the latest commit SHA for `custom/setup/` in BCQuality:
   `https://api.github.com/repos/Curabis/BCQuality/commits?path=custom/setup&per_page=1`
2. Read stored SHA from `~/.claude/.bcquality-version` (may not exist yet)
3. If SHA is different (or file missing):
   a. Fetch and execute Mode B from:
      `https://raw.githubusercontent.com/Curabis/BCQuality/main/custom/setup/curabis-standard.agent.md`
   b. Write new SHA to `~/.claude/.bcquality-version`
   c. Report: "BCQuality opdateret til [short-sha] — [antal] filer tjekket"
4. If SHA is unchanged: continue silently

Do this silently and quickly — do not ask for permission, do not explain the process
unless something actually changed.

## CURABIS Standard project setup

When the user says either of these commands, fetch and follow the setup agent:

```
https://raw.githubusercontent.com/Curabis/BCQuality/main/custom/setup/curabis-standard.agent.md
```

- **"Konfigurer dette projekt til CURABIS Standard"** → fuld setup af nyt repo
- **"Opdater CURABIS Standard fra BCQuality"** → manuel opdatering

## Identity

- Organization: CURABIS ApS
- BC MCP bridge is installed at `~/.claude/bc-mcp-bridge.js`
- BC MCP credentials are at `~/.bc-mcp.config.json` (never commit this file)

<!-- Replace the two lines below with your own details -->
- User: [Your Name] (username: [your-username])
