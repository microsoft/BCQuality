#!/usr/bin/env node
// bc-mcp-bridge.js
// Lokal stdio <-> streamable-HTTP bro mellem Claude Code og BC MCP-serveren.
// S2S-auth (client credentials) - ingen bruger-login. Broen henter + fornyer token selv,
// og injicerer routing-headers. Claude Code taler stdio til broen (intet DCR/OAuth-problem).
//
// Config: Scripts/bc-mcp.config.json (GITIGNORED) eller env-vars:
//   BC_MCP_TENANT, BC_MCP_CLIENT_ID, BC_MCP_CLIENT_SECRET,
//   BC_MCP_ENVIRONMENT (default Production), BC_MCP_COMPANY, BC_MCP_CONFIG (default CURABIS_DEV)
//
// .mcp.json:
//   "businesscentral": { "command": "node", "args": ["Scripts/bc-mcp-bridge.js"] }

const fs = require("fs");
const path = require("path");

const ENDPOINT = "https://mcp.businesscentral.dynamics.com";
// 2026-08-04: neither fetch() call below had a timeout, and the BC session
// (sessionId) + underlying HTTP connection were reused for the bridge
// process's entire lifetime with no proactive refresh. A long-running Claude
// Code session with gaps between calls can leave either stale -- observed as
// a 30-minute hang on one call, and separately as an "Internal_CompanyNotFound"
// that wasn't actually a company problem. REQUEST_TIMEOUT_MS + the one-retry
// wrapper below fail fast and self-heal with a forced-fresh session instead.
const REQUEST_TIMEOUT_MS = 30000;

function die(m) { process.stderr.write(`[bc-mcp-bridge] ${m}\n`); process.exit(1); }

function loadConfig() {
  let c = {};
  // Soeger: 1) repo-lokal Scripts/bc-mcp.config.json  2) pr-maskine ~/.bc-mcp.config.json
  const home = process.env.USERPROFILE || process.env.HOME || "";
  for (const f of [path.join(__dirname, "bc-mcp.config.json"), path.join(home, ".bc-mcp.config.json")]) {
    if (fs.existsSync(f)) {
      try { c = JSON.parse(fs.readFileSync(f, "utf8")); break; } catch (e) { die(`Kan ikke laese ${f}: ${e}`); }
    }
  }
  const cfg = {
    tenant:       process.env.BC_MCP_TENANT        || c.tenant,
    clientId:     process.env.BC_MCP_CLIENT_ID     || c.clientId,
    clientSecret: process.env.BC_MCP_CLIENT_SECRET || c.clientSecret,
    environment:  process.env.BC_MCP_ENVIRONMENT   || c.environment       || "Production",
    company:      process.env.BC_MCP_COMPANY       || c.company,
    config:       process.env.BC_MCP_CONFIG        || c.configurationName  || "CURABIS_DEV",
  };
  for (const k of ["tenant", "clientId", "clientSecret", "company"]) {
    if (!cfg[k]) die(`Mangler config '${k}' - saet i Scripts/bc-mcp.config.json eller env-var.`);
  }
  return cfg;
}

const cfg = loadConfig();
let token = null, tokenExp = 0, sessionId = null, lastInitializeMsg = null, lastActivityAt = 0;
// 2026-08-07: the reactive re-initialize below only fires after BC has already
// rejected a request. It self-heals invisibly to the caller, but still burns
// two round trips (reject, initialize, retry) on the first call after any idle
// gap. A client that opens a fresh session per call (e.g. a Power Automate
// flow) never hits this at all, which is why it reads as more stable than a
// long-lived interactive session that caches sessionId for its whole
// lifetime. Proactively refreshing before a call that has been idle a while
// gets the same effective robustness without waiting for BC to reject first.
// No API exposes the session's actual TTL, so this threshold is a heuristic,
// not a documented guarantee.
const SESSION_IDLE_THRESHOLD_MS = 3 * 60 * 1000; // 3 min

async function getToken() {
  if (token && Date.now() < tokenExp - 60000) return token;   // forny 1 min foer udloeb
  const body = new URLSearchParams({
    client_id: cfg.clientId,
    client_secret: cfg.clientSecret,
    scope: `${ENDPOINT}/.default`,
    grant_type: "client_credentials",
  });
  const r = await fetch(`https://login.microsoftonline.com/${cfg.tenant}/oauth2/v2.0/token`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body,
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
  });
  if (!r.ok) throw new Error(`token ${r.status}: ${await r.text()}`);
  const j = await r.json();
  token = j.access_token;
  tokenExp = Date.now() + (j.expires_in || 3600) * 1000;
  return token;
}

// BC kraever Base64 hvis header-vaerdien har ikke-ASCII (ae/oe/aa).
const enc = v => /[^\x00-\x7F]/.test(v) ? `=?base64?${Buffer.from(v, "utf8").toString("base64")}?=` : v;

// 2026-08-07: neither of the two "clear sessionId and reinitialize" paths below
// ever told BC the old session was actually done -- they just drop the local
// sessionId variable and let a fresh session get issued on the next call. The
// MCP Streamable HTTP transport spec defines an explicit way to end a session
// cleanly: an HTTP DELETE to the same endpoint carrying the session's
// Mcp-Session-Id. This bridge has never called it. Trying it now as a
// candidate fix for the recurring Internal_CompanyNotFound pattern (retry
// after a client-side session reset does NOT clear it; a manual save on the
// BC-side MCP Server Configuration record does) -- if BC's server-side session
// state is what's actually stuck, telling it explicitly to close might do the
// same job the manual config-save has been doing by accident. Best-effort and
// silent on failure: if BC responds 404/405 (DELETE not implemented), that is
// itself useful evidence for the Microsoft support escalation, not a bug here.
async function closeSession(oldSessionId) {
  if (!oldSessionId) return;
  try {
    const tok = await getToken();
    const r = await fetch(ENDPOINT, {
      method: "DELETE",
      headers: {
        "Authorization": `Bearer ${tok}`,
        "TenantId": cfg.tenant,
        "EnvironmentName": cfg.environment,
        "Company": enc(cfg.company),
        "ConfigurationName": enc(cfg.config),
        "Mcp-Session-Id": oldSessionId,
      },
      signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
    });
    process.stderr.write(`[bc-mcp-bridge] closed session ${oldSessionId}: HTTP ${r.status}\n`);
  } catch (e) {
    process.stderr.write(`[bc-mcp-bridge] session close failed (non-fatal): ${e.message || e}\n`);
  }
}

function parseSSE(text) {
  const msgs = [];
  for (const block of text.split(/\r?\n\r?\n/)) {
    const data = block.split(/\r?\n/).filter(l => l.startsWith("data:")).map(l => l.slice(5).replace(/^ /, ""));
    if (data.length) { const p = data.join("\n").trim(); if (p && p !== "[DONE]") msgs.push(p); }
  }
  return msgs;
}

async function forwardOnce(msg) {
  const tok = await getToken();
  const headers = {
    "Authorization": `Bearer ${tok}`,
    "Content-Type": "application/json",
    "Accept": "application/json, text/event-stream",
    "TenantId": cfg.tenant,
    "EnvironmentName": cfg.environment,
    "Company": enc(cfg.company),
    "ConfigurationName": enc(cfg.config),
  };
  if (sessionId) headers["Mcp-Session-Id"] = sessionId;
  const r = await fetch(ENDPOINT, {
    method: "POST",
    headers,
    body: JSON.stringify(msg),
    signal: AbortSignal.timeout(REQUEST_TIMEOUT_MS),
  });
  const sid = r.headers.get("mcp-session-id"); if (sid) sessionId = sid;
  const ct = r.headers.get("content-type") || "";
  const text = await r.text();
  // 2026-07-31: BC has returned error bodies as plain JSON while still labelling
  // content-type text/event-stream (e.g. "company not found"). parseSSE only
  // extracts lines starting with "data:" - a plain JSON error body has none, so
  // it silently returned []. The stdin loop then wrote nothing at all, and the
  // client (Claude Code) waited out its own 30s timeout instead of seeing the
  // real error immediately. Check !r.ok BEFORE any SSE parsing, unconditionally -
  // never let a non-2xx response fall through to parseSSE.
  if (!r.ok) throw new Error(`HTTP ${r.status}: ${text || "(empty body)"}`);
  return ct.includes("text/event-stream") ? parseSSE(text) : (text.trim() ? [text.trim()] : []);
}

async function forward(msg) {
  if (msg.method === "initialize") lastInitializeMsg = msg;
  if (sessionId && msg.method !== "initialize" && lastActivityAt &&
      Date.now() - lastActivityAt > SESSION_IDLE_THRESHOLD_MS) {
    process.stderr.write(`[bc-mcp-bridge] session idle ${Math.round((Date.now() - lastActivityAt) / 1000)}s, refreshing proactively\n`);
    await closeSession(sessionId);
    sessionId = null;
    if (lastInitializeMsg) {
      try {
        await forwardOnce(lastInitializeMsg);
      } catch (initErr) {
        process.stderr.write(`[bc-mcp-bridge] proactive re-initialize failed: ${initErr.message || initErr}\n`);
      }
    }
  }
  try {
    const result = await forwardOnce(msg);
    lastActivityAt = Date.now();
    return result;
  } catch (e) {
    // 2026-08-04: one retry with a forced-fresh BC session (sessionId cleared).
    // A long-idle Claude Code session can leave the cached Mcp-Session-Id or
    // the underlying HTTP connection stale -- observed as a request hanging
    // until REQUEST_TIMEOUT_MS, or as an "Internal_CompanyNotFound" that was
    // actually a dead session, not a real company problem. Quick, frequent
    // calls never idle long enough to hit this; a long session with gaps
    // between calls does.
    process.stderr.write(`[bc-mcp-bridge] retrying after: ${e.message || e}\n`);
    await closeSession(sessionId);
    sessionId = null;
    // 2026-08-05: clearing sessionId is not enough on its own. BC's own error
    // is explicit -- "A new session can only be created by an initialize
    // request" -- so simply resending the original non-initialize message
    // with no session header reproduces the exact same error, not a fresh
    // session. Replay the client's actual initialize message first (cached
    // above, the only thing BC will accept to hand out a new session), THEN
    // retry the original call with the session that establishes. If there's
    // no cached initialize yet (this failure IS the very first call, or is
    // itself the initialize), skip straight to the plain retry below.
    if (msg.method !== "initialize" && lastInitializeMsg) {
      try {
        await forwardOnce(lastInitializeMsg);
      } catch (initErr) {
        process.stderr.write(`[bc-mcp-bridge] re-initialize failed: ${initErr.message || initErr}\n`);
        // Fall through anyway -- retrying the original message will still
        // surface a clear, real error if the session truly can't be restored.
      }
    }
    const result = await forwardOnce(msg);
    lastActivityAt = Date.now();
    return result;
  }
}

// Splits text into chunks of max maxLen chars, breaking at word boundaries.
function splitTextToChunks(text, maxLen = 250) {
  const chunks = [];
  while (text.length > maxLen) {
    let cut = text.lastIndexOf(" ", maxLen);
    if (cut <= 0) cut = maxLen; // no space found — hard cut
    chunks.push(text.slice(0, cut).trimEnd());
    text = text.slice(cut).trimStart();
  }
  if (text) chunks.push(text);
  return chunks;
}

// Intercepts Create_TaskComment calls with comment > 250 chars and splits into multiple lines.
// Each chunk is sent in its own fresh BC session so GetNextLineNo sees previously committed records.
async function dispatchCreateComment(msg) {
  const args = (msg.params && msg.params.arguments) || {};
  const comment = args.comment || "";
  const chunks = splitTextToChunks(comment);
  let tempId = Date.now();
  const savedSessionId = sessionId;   // preserve the main conversation session
  for (const chunk of chunks) {
    sessionId = null;                  // fresh session per chunk → independent BC transaction
    const chunkMsg = {
      ...msg,
      id: tempId++,
      params: { ...msg.params, arguments: { ...args, comment: chunk } },
    };
    await forward(chunkMsg);
    sessionId = null;                  // discard the chunk session — never bleed into next chunk
  }
  sessionId = savedSessionId;          // restore main session for subsequent calls
  return [JSON.stringify({
    jsonrpc: "2.0", id: msg.id,
    result: { content: [{ type: "text", text: `Kommentar gemt i ${chunks.length} linje(r).` }] },
  })];
}

// stdio-loop: newline-delimited JSON-RPC (MCP stdio-transport).
let buf = "";
process.stdin.setEncoding("utf8");
process.stdin.on("data", async (chunk) => {
  buf += chunk;
  let i;
  while ((i = buf.indexOf("\n")) >= 0) {
    const line = buf.slice(0, i).trim();
    buf = buf.slice(i + 1);
    if (!line) continue;
    let msg;
    try { msg = JSON.parse(line); } catch { continue; }
    try {
      const isCreateComment =
        msg.method === "tools/call" &&
        msg.params?.name === "Create_TaskComment_PAG6102902" &&
        (msg.params?.arguments?.comment || "").length > 250;
      const responses = isCreateComment
        ? await dispatchCreateComment(msg)
        : await forward(msg);
      for (const out of responses) process.stdout.write(out + "\n");
    } catch (e) {
      process.stderr.write(`[bc-mcp-bridge] ${e.message || e}\n`);
      if (msg.id !== undefined && msg.id !== null) {
        process.stdout.write(JSON.stringify({
          jsonrpc: "2.0", id: msg.id, error: { code: -32000, message: String(e.message || e) },
        }) + "\n");
      }
    }
  }
});
process.stdin.on("end", () => process.exit(0));
