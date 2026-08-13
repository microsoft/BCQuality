---
bc-version: [all]
domain: mcp
keywords: [api-page, least-privilege, write-access, odata, security, external-api, identity-fields]
technologies: [al]
countries: [w1]
application-area: [all]
---
# CURABIS MCP: API Pages Must Use Least-Privilege Write Access

## Description

A general-purpose API page that exposes many fields should not be widened to allow writes on a single additional field. Instead, create a dedicated minimal API page that exposes only the fields the consumer needs to read and write. This limits the blast radius of any agent or integration mistake.

This applies beyond CURABIS's own MCP tooling — it's a general AL API-page design concern. Any `PageType = API` page consumed by an external integration, a Power BI dataset, or a partner system carries the same risk: a write-enabled page with no per-field restriction is a wide-open surface regardless of who or what is calling it.

## Why This Matters

An MCP agent operates with the permissions of its service identity, not an individual user — but the same argument holds for any external consumer of an API page. A page that allows writing to many fields gives the caller broad power that is hard to audit and easy to misuse, whether the caller is CURABIS's own agent, a customer's integration, or a Power Platform flow. A dedicated page with one writable field (or explicit `Editable = false` on everything else) makes the intent explicit and the surface area auditable.

## Pattern to Avoid

The most common real-world shape of this violation isn't a page that started narrow and got widened — it's a page that was **never restricted at all**. A `PageType = API` page with `InsertAllowed`/`ModifyAllowed`/`DeleteAllowed` left at their defaults, and no `Editable = false` on any field, exposes every field on the source table — including identity fields (`No.`, `Document Type`) and financially significant ones (`VAT Bus. Posting Group`, `Amount Including VAT`) — as fully writable, with nothing marking that as deliberate:

    // WRONG: no restriction declared anywhere on a write-capable API page —
    // ~90 fields, including VAT/posting fields and the record's own key,
    // are all fully writable by default, with nothing marking that as intentional.
    page 50100 "Some Document Header API"
    {
        PageType = API;
        APIPublisher = 'contoso';
        APIGroup = 'docs';
        APIVersion = 'v1.0';
        SourceTable = "Some Document Header";
        // no InsertAllowed/ModifyAllowed/DeleteAllowed override, no Editable = false anywhere
        layout
        {
            area(content)
            {
                repeater(GroupName)
                {
                    field(no; Rec."No.") { }
                    field(documentType; Rec."Document Type") { }
                    field(amountIncludingVAT; Rec."Amount Including VAT") { }
                    field(vatBusPostingGroup; Rec."VAT Bus. Posting Group") { }
                    // ... ~85 more fields, none marked Editable = false
                }
            }
        }
    }

The narrower "widened by one field" shape below is also real, just less common in practice than the above:

    // WRONG: General page widened with write access to one field
    // Now the agent can accidentally (or intentionally) write to all other fields too
    field(status; Rec.Status) { }                          // should be read-only
    field(gitHubRepository; Rec."GitHub Repository") { }   // the one field we want writable
    field(estimatedHours; Rec."Estimated Hours") { }        // should be read-only

## Correct Pattern

Create a separate, minimal API page:

    page 6102904 "CUR MCP Project Repository"
    {
        // Only two fields: the key and the one writable field
        field(no; Rec."No.") { Editable = false; }
        field(gitHubRepository; Rec."GitHub Repository") { }
    }

## Requirements

- Each distinct write concern (e.g., setting a GitHub repo, updating a dev status) should have its own API page or be deliberately grouped only with closely related fields
- Read-only fields on write-enabled pages must carry `Editable = false`
- The page description must document which fields are writable and why

## Verification

For each API page where `ModifyAllowed = true` (or default), list all fields without `Editable = false`. Confirm that every writable field is intentionally writable for the same consumer use case. If unrelated fields are writable on the same page, split the page.
