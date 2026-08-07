---
bc-version: [all]
domain: mcp
keywords: [businesscentral, mcp, bc-mcp-bridge, company, header, display-name, config, troubleshooting]
technologies: [al, mcp]
countries: [w1]
application-area: [all]
---

# BC MCP `Company` Header Must Be the Exact `Navn` Field, Not `Vist navn`

## Description

`~/.bc-mcp.config.json`'s `company` value is sent as the literal `Company`
HTTP header to the BC MCP endpoint. It must exactly match the company's
**`Navn`** field in Business Central's company list — not the **`Vist navn`**
(display name) field. The two are often different strings for the same
company, and BC's own company picker UI shows the display name more
prominently, making it the natural (wrong) one to copy.

## Incident (2026-07-31)

CURABIS's own `businesscentral` MCP server failed after "working all
evening" with a generic client-side "connection timed out after 30000ms" —
no useful error surfaced to the developer. Root cause: `company` was set to
`"CURABIS ApS"` (the `Vist navn`), while BC's actual `Navn` field is
`"Curabis ApS"`. BC's own API rejected the mismatched header with a fast,
clear 400 error — but `bc-mcp-bridge.js` had a separate bug
(`bc-mcp-bridge-must-surface-non-2xx-responses-before-sse-parsing`, same
incident) that swallowed the error body, turning a sub-200ms server error
into a 30-second client-side hang with no diagnostic.

## Verification

If `businesscentral` MCP fails, check BC's company list page (Virksomheder /
Companies) and compare the `Navn` column — not `Vist navn` — against
`~/.bc-mcp.config.json`'s `company` value, character for character. Do not
assume the value that "looks right" from the picker UI is the one the API
needs.

## Anti-Pattern

    // WRONG: copied from BC's company switcher, which shows Vist navn
    { "company": "CURABIS ApS" }

## Compliant

    // CORRECT: copied from the Navn column on the company list page
    { "company": "Curabis ApS" }

## Scope

Every machine with `~/.bc-mcp.config.json` configured — this is a
machine-local file, not something Mode B can fix centrally. The template
(`bc-mcp.config.template.json`) carries an explicit warning about this
distinction as of 2026-07-31, but a machine already onboarded before that
date needs its existing file checked manually.

## Follow-up (2026-08-03) — a correct header does not guarantee the request resolves

The `Internal_CompanyNotFound` symptom recurred on 2026-08-03 on two
independent developer machines, both with `company` already set to the
correct `Navn` value (`"Curabis ApS"`) per this rule. The header-mismatch
cause above was confirmed absent both times — yet the error still occurred,
intermittently, within the same working day.

This means a correct `Navn`-matching header is **necessary but not
sufficient**: the same-looking error can have a second cause unrelated to
the header value. When this happens, the header-match check (Verification,
above) has nothing left to find — do not keep re-checking that same field.

**Ruled out on 2026-08-03, with evidence — do not re-investigate these:**
- **Stale client process.** A theory that a long-running `bc-mcp-bridge.js`
  process was running pre-fix code from before its 2026-08-01 update, and
  that restarting Claude Code would pick up the fix. **Falsified same day:**
  a full machine reboot (strictly stronger than a Claude Code restart — kills
  every process, clears all in-memory state, re-establishes every network
  connection) left the exact same error unchanged immediately after. An
  earlier apparent "it works after a restart" observation was very likely
  coincidental with an intermittent server-side state, not causal.
- **MCP Server Configuration misconfigured.** Verified via BC UI screenshot:
  `CURABIS_DEV` configuration is `Aktiv` (Active) = on, `Standard` (Default)
  = on, with the expected tool set and permissions present.
- **Company record wrong or `Navn` mismatched.** Verified via BC UI
  screenshot of the company list: `Navn` = `Curabis ApS` exactly (matches
  config character-for-character), `Vist navn` = `CURABIS ApS` (confirming
  why the original 2026-07-31 mix-up was easy to make), setup status
  `Completed`.

**Conclusion:** with the header confirmed correct, the MCP configuration
confirmed active/default, and the company record confirmed correct — all
via direct BC UI inspection, not inference — and the error still recurring
intermittently, immune even to a full machine reboot, this is not a client-
fixable condition. Escalate to Microsoft support with the evidence bundle
(exact error text, `~/.bc-mcp.config.json` values, both BC UI screenshots,
and timestamps of both failing and working calls) rather than continuing
local troubleshooting. Root cause of the intermittent failure itself remains
unconfirmed — likely a BC/SaaS-side condition outside CURABIS's visibility.
