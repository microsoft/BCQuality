---
bc-version: [all]
domain: mcp
keywords: [al-mcp, projectpath, invalid-uri, relative-path, al_build, al_publish]
technologies: [al]
countries: [w1]
application-area: [all]
---

# al MCP server's al_build/al_publish require an absolute projectPath

## Description

When calling the `al` MCP server's `al_build` or `al_publish` tools, the `projectPath`
parameter must be an absolute path. A relative path — even a simple sibling-folder
form like `"../MyApp.Test"` or `"Apps/MyApp.Test"` — reliably fails with:

    Invalid URI: The format of the URI could not be determined.

## Why

This failure mode is misleading: the error looks like a server-connection or
environment problem (matching several of the tool's own suggested causes —
"Extension internal error", "Unexpected system state"), not a path-formatting
issue. An agent chasing it will burn time retrying authentication, symbol
downloads, or environment parameters before finding the actual cause.

The same relative path works fine on `al_downloadsymbols`, which makes the
failure look tool-specific and inconsistent rather than a clear, learnable
rule — reinforcing the wrong hypothesis (auth/environment) instead of the
right one (path form).

## How to apply

Always resolve `projectPath` to an absolute path before calling `al_build` or
`al_publish`:

    al_build({ projectPath: "D:\\Repo\\Apps\\MyApp.Test", onlyErrors: true })
    al_publish({ projectPath: "D:\\Repo\\Apps\\MyApp.Test", skipBuild: true, ... })

If only `appPath` is available (pointing directly at a built `.app` file) with
`skipBuild: true`, a relative path there is tolerated — the bug is specific to
`projectPath` on `al_build`/`al_publish`, not to relative paths in general on
every parameter of every `al` MCP tool.

## What NOT to do

- Do not pass a relative `projectPath` to `al_build` or `al_publish`, even one
  that resolves correctly on disk (e.g. verified via a shell `cd`).
- Do not diagnose "Invalid URI" from these two tools as an auth, tenant, or
  environment-name problem before first checking whether `projectPath` is
  relative.
- Do not conclude the `al` MCP server itself is broken/unreachable from this
  error alone — `al_downloadsymbols` and other tools may work fine in the same
  session with the same relative path.

## Applies to

All CURABIS projects using the `al` MCP server (any repo with the standard
`al` entry in `.mcp.json`, machine-global per the v24 CURABIS Standard).
