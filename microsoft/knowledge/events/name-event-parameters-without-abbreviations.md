---
bc-version: [all]
domain: events
keywords: [parameter-naming, readability, conventions, event-parameters, no-abbreviations, integration-event, clarity]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Name event parameters without abbreviations

## Description

Event parameter names are part of the public contract a subscriber codes against, so they must be self-explanatory. Record parameters take the full table name with the spaces removed — `SalesHeader` for `"Sales Header"`, not `SalesHdr` or `SH`. Simple parameters get a descriptive, spelled-out name — `DocumentNo`, not `DocNo`; `Amount`, not `Amt`. Abbreviated names force every subscriber author to guess intent and tend to be inconsistent across a codebase, where the same concept appears under several contractions. The cost of a clear name is paid once at the publisher; the cost of a cryptic one is paid by every subscriber that has to decode it.

## Best Practice

Use full, unabbreviated names: `(SalesHeader: Record "Sales Header"; DocumentNo: Code[20]; Amount: Decimal)`. Record parameters mirror the table name without spaces, and value parameters read as whole words so the contract is unambiguous.

See sample: `name-event-parameters-without-abbreviations.good.al`.

## Anti Pattern

Abbreviated parameter names (`SalesHdr`, `DocNo`, `Amt`) that obscure meaning and vary across publishers, so subscribers must guess what each one holds. Detection: event parameters whose names are truncated forms of the table name or contracted words rather than the full term.

See sample: `name-event-parameters-without-abbreviations.bad.al`.
