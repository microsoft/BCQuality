---
bc-version: [all]
domain: architecture
keywords: [release-process, stable, promote, setup-agent, templates, atomicity, broken-fetch]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Setup docs must not reference files not yet promoted to stable

## Description

The setup agent and other BCQuality documents fetch artifacts via the
`stable`-based BASE URLs. When a change that INTRODUCES a reference to a new
file (e.g. a new template in the Mode B table) is merged to `main` but not
yet promoted, every consumer in that window follows the document's own
documented path and gets a 404 — the document instructs a fetch its own
release channel cannot serve.

This happened in practice: setup v16 added a Mode B row fetching
`{BASE}/templates/find-altool.ps1`; the file existed on `main` only. A
session on a developer machine (ConzeptALGo, 2026-07-03) hit the 404,
verified both branches with curl, and — correctly — refused to fall back to
`main`, since bypassing the vetted channel would defeat its purpose. The
observation, evidence and this rule's filename come from that session: the
first field-originated Type B proposal in BCQuality's history.

## Rule

A change to `curabis-standard.agent.md` (or any consumer-facing document)
that introduces a reference to a NEW file via a `stable`-based URL must not
sit merged on `main` without the referenced file being available on
`stable`. In practice:

1. The referenced file and the reference ship in the SAME pull request —
   they cannot drift apart.
2. The promote follows the merge immediately when a PR introduces new
   artifact references. Merge and promote are one operation for
   reference-introducing changes, not two events with an open-ended window.
3. Consumers (sessions, Mode B) that hit a 404 on a documented stable path
   report the gap — they never silently fetch from `main` instead. The
   channel discipline outranks the convenience.
4. **Channel-state evidence comes from git, never from a CDN.** Verify with
   `git ls-remote`/a fresh clone — raw-URL caches lag minutes behind, so a
   404/200 observed right after a promote can be stale. Two true
   observations can contradict each other when the world moves between
   them: timestamp every piece of channel evidence before acting on it.
   (Field-verified 2026-07-03: a session's real 404 was fixed mid-flight;
   it re-verified by cloning the branch and correctly withdrew its case.)

## What NOT to do

- Do not merge a reference-introducing setup change and leave the promote
  "for later" — the window is a live outage for every Mode B run
- Do not let automation fall back to `main` when `stable` 404s — that
  silently converts the release gate into decoration
- Do not fix the window by pointing BASE at `main` — the channel is the
  feature; the discipline around it is what needs to hold

## Signal to watch for

During Mode B or any documented fetch: HTTP 404 on a `stable`-based URL that
the current setup document itself references. That is always a release-
process gap, never a consumer error.

## Message to developer

When a documented stable fetch 404s, report: this file is referenced by the
current setup document but has not been promoted to stable yet — the
maintainer must promote (or the reference merged prematurely); continuing
with a main-fallback is not permitted.
