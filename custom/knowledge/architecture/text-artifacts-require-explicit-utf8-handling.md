---
bc-version: [all]
domain: architecture
keywords: [encoding, utf-8, powershell, mojibake, here-string, bom, raw-bytes]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Text artifacts require explicit UTF-8 handling — no ambient encoding

## Description

Two production incidents, same disease, different vectors. (1)
`smiley.agent.md` shipped double-UTF-8-encoded for weeks: fetched as string
content over HTTP and re-saved with ambient encoding — every em-dash became
`â€"`, and `file` misclassified the agent as Nim source code. (2) A Mode B
batch script wrote the SAME mojibake into three project CLAUDE.md files:
Windows PowerShell 5.1 reads a BOM-less `.ps1` as cp1252, so UTF-8 em-dashes
inside a here-string were mis-decoded before they were ever written. Both
incidents corrupted deployed instruction files silently; both were caught by
inspection, not by tooling.

The root cause is never the characters — it is trusting an AMBIENT encoding
(HTTP string decoding, PS 5.1 script parsing, `Out-File` defaults) anywhere
between a text artifact's source and its destination.

## Rule

When creating, fetching or transforming CURABIS text artifacts (agent files,
CLAUDE.md, knowledge files, scripts):

1. **Transfers are raw bytes.** Filesystem `Copy-Item` or
   `Invoke-WebRequest -OutFile` — never via `.Content` strings.
2. **Writes are explicit UTF-8.** `[System.IO.File]::WriteAllText(path,
   text, [System.Text.UTF8Encoding]::new($false))` — never `Out-File` /
   `Set-Content` defaults for content with non-ASCII.
3. **Text transformation with non-ASCII happens in Python** (explicit
   `encoding="utf-8"` on read AND write) — or, if it must be PowerShell, the
   `.ps1` file itself carries a UTF-8 BOM so PS 5.1 parses its literals
   correctly. A BOM-less `.ps1` with non-ASCII literals is a latent bug.
4. **Verify after generation:** grep the output for `â€` (the mojibake
   signature) before committing or deploying. One line, catches the class.

## What NOT to do

- Do not put em-dashes, æøå or any non-ASCII inside a here-string in a
  `.ps1` that lacks a BOM — the corruption happens at parse time, before
  your code runs
- Do not fetch a file via `.Content` and re-save it — the double-decode is
  invisible until someone reads the artifact
- Do not assume "it looked fine in my editor" — editors auto-detect; parsers
  and runtimes do not

## Signal to watch for

The literal byte sequence `â€` (or `Ã¦`, `Ã¸`, `Ã¥`) in any committed or
deployed text file. Also: `file`/tooling misclassifying a markdown file as
source code — that is encoding damage until proven otherwise.

## Message to developer

When mojibake is found in an artifact, report which file, repair by
cp1252→UTF-8 reversal (line-by-line fallback preserves already-correct
lines), and identify WHICH transfer step used ambient encoding — the repair
without the root cause just schedules the next incident.
