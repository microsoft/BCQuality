---
bc-version: [all]
domain: performance
keywords: [confirm, strmenu, message, transaction, dialog]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Do not prompt the user inside a write transaction

> **Seed article.** Converted from an existing performance-review prompt to bootstrap the BCQuality performance corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Confirm, StrMenu, Message, and any other user-facing dialog pauses execution while the transaction is still open. During that pause every lock held by the transaction blocks other sessions. A user who walks away from the screen can suspend business-critical tables for an unbounded period.

## Best Practice

Gather every user decision before the writing phase begins. Once the decisions are known, run the transaction end-to-end without prompts.

See sample: `avoid-user-interaction-in-transactions.good.al`.

## Anti Pattern

Calling Confirm or StrMenu from inside an OnInsert, OnModify, or OnDelete trigger — or from any code path that has already started modifying records — blocks on user input while holding locks.

See sample: `avoid-user-interaction-in-transactions.bad.al`.

