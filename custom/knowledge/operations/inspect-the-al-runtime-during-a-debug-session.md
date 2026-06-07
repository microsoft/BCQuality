---
bc-version: [28]
domain: operations
keywords: [troubleshooting-mcp-server, debug, call-stack, runtime, copilot, breakpoint]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Inspect the AL runtime during a debug session

## Description

The Troubleshooting MCP Server lets GitHub Copilot Chat read the live AL runtime state during an active debug session: the call stack, the variables at any frame, the source for a frame, and a breakpoint set by object and line number while paused. It is available only while a debug session is paused at a breakpoint or a runtime error, and only on BC 2026 release wave 1 (BC 28) or later. It is the right surface when you want a natural-language explanation that follows a deep call stack or an answer to why a particular code path executed, rather than stepping through manually.

What it reads is the runtime as it stands at the pause point, so it answers questions about the present state of an execution rather than its history. The value over manual stepping is that Copilot can fan out across many frames and variables at once and summarise them, which is exactly the work that is tedious to do by hand on a deep stack. It reads; it does not write, step, or apply fixes.

## Best Practice

Reach for the Troubleshooting MCP Server when a runtime error has fired or a paused stack is deep across many objects and you want it summarised, or when you want to know why a branch took a particular path without manual stepping. Pause at the breakpoint or error first, then ask Copilot explicitly to use the server, since it does not always reach for it on its own. Use the variable inspection to surface database statistics (SQL latency, executes, row reads) that traditional stepping hides, which is good for spotting hidden DB calls in subscribers. Pair it with the performance profiler: profile first for slowness, then set a breakpoint at the slow frame and ask the Troubleshooting MCP for the runtime detail.

## Anti Pattern

Using it for the wrong job or expecting capabilities it does not have. It is not a replacement for interactive step-through debugging, for a quick look at one variable, or for learning unfamiliar code by reading it. It offers no time travel, so it only shows what is in scope right now, and it returns no source for frames whose code lives only in compiled .app packages, where you fall back to inspecting variables. The signal of misuse: trying to invoke it with no active paused debug session, on a version before BC 28, or expecting it to replay history or auto-apply fixes.

## See also

- `run-headless-al-builds-with-the-al-mcp-server.md`
