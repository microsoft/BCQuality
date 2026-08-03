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
