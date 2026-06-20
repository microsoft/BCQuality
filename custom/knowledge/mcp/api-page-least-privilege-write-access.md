# CURABIS MCP: API Pages Must Use Least-Privilege Write Access

## Core Principle

A general-purpose API page that exposes many fields should not be widened to allow writes on a single additional field. Instead, create a dedicated minimal API page that exposes only the fields the consumer needs to read and write. This limits the blast radius of any agent or integration mistake.

## Why This Matters

An MCP agent operates with the permissions of its service identity, not an individual user. A page that allows writing to many fields gives the agent broad power that is hard to audit and easy to misuse. A dedicated page with one writable field makes the intent explicit and the surface area auditable.

## Pattern to Avoid

```al
// WRONG: General page widened with write access to one field
// Now the agent can accidentally (or intentionally) write to all other fields too
field(status; Rec.Status) { }                          // should be read-only
field(gitHubRepository; Rec."GitHub Repository") { }   // the one field we want writable
field(estimatedHours; Rec."Estimated Hours") { }        // should be read-only
```

## Correct Pattern

Create a separate, minimal API page:

```al
page 6102904 "CUR MCP Project Repository"
{
    // Only two fields: the key and the one writable field
    field(no; Rec."No.") { Editable = false; }
    field(gitHubRepository; Rec."GitHub Repository") { }
}
```

## Requirements

- Each distinct write concern (e.g., setting a GitHub repo, updating a dev status) should have its own API page or be deliberately grouped only with closely related fields
- Read-only fields on write-enabled pages must carry `Editable = false`
- The page description must document which fields are writable and why

## Verification

For each API page where `ModifyAllowed = true` (or default), list all fields without `Editable = false`. Confirm that every writable field is intentionally writable for the same consumer use case. If unrelated fields are writable on the same page, split the page.
