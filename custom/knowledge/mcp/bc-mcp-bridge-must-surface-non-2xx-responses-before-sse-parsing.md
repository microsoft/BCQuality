---
bc-version: [all]
domain: mcp
keywords: [businesscentral, mcp, bc-mcp-bridge, error-handling, sse, timeout, troubleshooting]
technologies: [al, mcp]
countries: [w1]
application-area: [all]
---

# bc-mcp-bridge.js Must Check `!r.ok` Before Any SSE Parsing, Unconditionally

## Description

`bc-mcp-bridge.js`'s `forward()` function decides how to parse the BC MCP
endpoint's response body based on its `content-type` header. Before
2026-07-31 it only treated a response as an error when `!r.ok && !text` —
i.e. only when there was no body at all. A non-2xx response WITH a body
(the common case — BC returns structured JSON error objects) fell through
to the content-type branch instead.

## Incident (2026-07-31)

BC returned a 400 with a plain JSON error body (`{"Error": {"Message":
"..."}}`) while still labelling the response `content-type:
text/event-stream`. `parseSSE()` only extracts lines starting with `data:` —
a plain JSON body has none, so it returned `[]` silently. The stdin loop's
`for (const out of responses) process.stdout.write(...)` then had nothing to
iterate, so the bridge produced **zero output** — not even to stderr — for a
request that BC had already answered in under 200ms. Claude Code had no
signal to work with and waited out its own 30-second client-side timeout,
which was the only thing the developer actually saw.

## Rule

Check `!r.ok` before considering content-type at all, and throw
unconditionally (with the body text included) when it's true. Never let a
non-2xx response reach `parseSSE` — a server is free to mislabel an error
body's content-type, and the client must not depend on that label being
honest.

## Anti-Pattern

    const ct = r.headers.get("content-type") || "";
    const text = await r.text();
    if (!r.ok && !text) throw new Error(`HTTP ${r.status}`);
    return ct.includes("text/event-stream") ? parseSSE(text) : [text.trim()];
    // A 400 WITH a body silently falls through to parseSSE and returns [].

## Compliant

    const ct = r.headers.get("content-type") || "";
    const text = await r.text();
    if (!r.ok) throw new Error(`HTTP ${r.status}: ${text || "(empty body)"}`);
    return ct.includes("text/event-stream") ? parseSSE(text) : [text.trim()];

## Scope

`bc-mcp-bridge.js` specifically, but the underlying principle generalizes to
any stdio MCP bridge that branches parsing logic on a server-supplied
content-type header: validate the HTTP status first, independent of what
the header claims the body's shape is.
