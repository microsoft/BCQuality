---
bc-version: [26..28]
domain: security
keywords: [inherentpermissions, attribute, least-privilege]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use InherentPermissions to grant minimal access

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

The InherentPermissions attribute attaches a minimum access grant to a procedure. Callers can invoke the procedure without holding the underlying tabledata right, because the attribute supplies exactly the right required by the procedure body and nothing more. InherentPermissions currently targets only objects owned by the same extension as the annotated procedure; it cannot be used to grant access to tables in other extensions or in the base application.

## Best Practice

Annotate read-only helper procedures with InherentPermissions specifying only the tables and access letters the body uses (typically 'r'). Callers do not need direct read rights on the underlying extension-owned table, so the calling role can be narrower. This is the narrowest of the elevation options and is appropriate for read-only lookup helpers.

See sample: `samples/security/use-inherent-permissions-to-grant-minimal-access/good.al`.

## Anti Pattern

A helper that reads a single lookup value but forces every calling role to hold tabledata read rights, because the helper does not declare its own inherent permissions. The broad read right then applies to every other code path that role can reach, not just the helper.

See sample: `samples/security/use-inherent-permissions-to-grant-minimal-access/bad.al`.

