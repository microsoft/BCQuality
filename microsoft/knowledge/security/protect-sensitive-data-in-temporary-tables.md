---
bc-version: [all]
domain: security
keywords: [temporary-table, data-protection, permission, cleanup]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Protect sensitive data in temporary tables

> Contributions welcome — open a PR to refine or extend this article.

## Description

A temporary record copies data out of the source table into session memory. The platform does not automatically enforce the source table's permission model on the copy, and a value written to a temporary buffer can outlive the procedure that put it there if the buffer is a global or is passed upward. Code that places sensitive rows into a temporary table is therefore responsible for the checks and cleanup the source table would otherwise provide.

## Best Practice

Validate the caller's read permission on the source table before populating the temporary buffer. Keep the buffer's lifetime as short as the work requires, and delete its contents on every exit path — including error paths — so sensitive values do not linger. Prefer local temporary variables over globals for anything carrying sensitive data.

See sample: `protect-sensitive-data-in-temporary-tables.good.al`.

## Anti Pattern

Copying records into a temporary buffer without a preceding permission check, and relying on procedure-exit to clean up. An exception before the explicit cleanup leaves the data in the buffer; a global or var-parameter buffer carries the data back to callers that may have no right to see it.

See sample: `protect-sensitive-data-in-temporary-tables.bad.al`.
