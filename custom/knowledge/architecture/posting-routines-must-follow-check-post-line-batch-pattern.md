---
bc-version: [all]
domain: architecture
keywords: [posting-routine, check-line, post-line, post-batch, companion-codeunit, sales-post, yes-no-wrapper, journal]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Posting routines must follow the Check Line / Post Line / Post Batch pattern

## Description

Every journal-based posting routine in Business Central is split across
three companion codeunits with distinct, non-overlapping responsibilities.
A new posting routine that doesn't follow this split — or a document
posting routine that doesn't follow its own variant of it — is either
missing functionality other code will expect, or exposing an interaction
surface it shouldn't.

## The Three Companion Codeunits

- **`<X> Check Line`** — validates one journal line. Reads from the
  database only the first time it's called (setup/dimension data), never
  again. No user interaction beyond error messages. Skips empty lines by
  exiting without error.
- **`<X> Post Line`** — writes exactly one line to the ledger and register
  tables. Does not read or update the Journal table itself — it only
  operates on the record variable passed to it. This is what makes it
  callable directly by other posting code (e.g. a document posting
  routine) without having to fabricate a Journal record first.
- **`<X> Post Batch`** — the only one of the three that reads and updates
  the Journal table. Loops calling `Check Line` for every line first, then
  loops calling `Post Line` for every line. Used only when the user
  chooses Post from the Journal page — never called by other posting code
  the way `Post Line` is.

None of these three codeunits shows UI beyond error messages. That is
deliberate: it lets them be called from other extensions or posting
routines without popups interrupting an unattended flow.

## Object Numbering Convention

The last digit of the companion codeunits' object IDs is conventionally
standardized: `1` = Check Line, `2` = Post Line, `3` = Post Batch (e.g.
`Gen. Jnl.-Check Line` = codeunit 11, `Gen. Jnl.-Post Line` = codeunit 12,
`Gen. Jnl.-Post Batch` = codeunit 13). New custom posting routines should
follow the same convention for consistency with the rest of the codebase.

## Document Posting Routines

A document posting routine (e.g. the `Sales-Post` codeunit) posts one
document at a time, so it calls the relevant `Post Line` companion
codeunits directly — bypassing `Post Batch` entirely, since a document
isn't posted as a looped batch of pre-existing journal lines.

## Never Call the Document-Post Codeunit Directly From a Page

A `-Post` document posting codeunit (like `Sales-Post`) must never be
called directly from a page. Pages call a `-Post (Yes/No)`
confirmation-wrapper codeunit instead, which asks the user to confirm,
then calls `-Post`. This keeps the core posting codeunit
interaction-free, so the same codeunit can also be driven unattended by a
"Batch Post" report that posts many documents in one run.

## Review Checklist

1. Does `Check Line` read from the database anywhere after its first
   call, or show any UI beyond an error? Either is a sign it's doing
   `Post Line`'s or `Post Batch`'s job.
2. Does `Post Line` read or write the Journal table directly? If so, it
   can no longer be called directly by other posting code without a
   Journal record — that's `Post Batch`'s job, not `Post Line`'s.
3. Is `Post Batch` the only one of the three touching the Journal table?
4. For a document posting routine: does it call `Post Line` directly
   rather than routing through `Post Batch`?
5. Is the `-Post` codeunit ever called directly from a page, instead of
   through a `-Post (Yes/No)` wrapper?

## Source

CURABIS Academy course "The Developers Guide through AL" (rev. July
2022), Chapter 4: Posting, "Posting Routines", "Posting Routine Companion
Codeunits", "Document Posting Routines" (p. 132–141). Cross-checked
against the current Base Application posting-codeunit structure (e.g.
`Gen. Jnl.-Check Line`/`Gen. Jnl.-Post Line`/`Gen. Jnl.-Post Batch`,
`Sales-Post`/`Sales-Post (Yes/No)`) as of 2026-08-13 — the pattern still
holds.
