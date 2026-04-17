---
bc-version: [26..28]
domain: security
keywords: [permissionset, least-privilege, rimd, tabledata]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Follow least privilege in permission sets

> **Seed article.** Converted from an existing security-review prompt to bootstrap the BCQuality security corpus. Domain stewards should expand, restructure, and refine as needed.

## Description

Permission sets define the tabledata and object rights granted to every user or role assigned to them. A permission set that grants RIMD on tabledata * hands every caller full control over every table the extension exposes, which is never the shape of access any real role requires. Over-broad permission sets are a persistent source of privilege-escalation risk: once assigned, they are rarely audited.

## Best Practice

Enumerate the specific tabledata objects a role needs and grant only the letters (R, I, M, D) that role genuinely uses. A sales order-entry role typically needs RIM on Sales Header, RIMD on Sales Line, and R on Customer — not blanket RIMD. Permission sets SHOULD be granular and role-shaped; a single permission set that covers every role in an extension is a design smell.

See sample: `follow-least-privilege-in-permission-sets.good.al`.

## Anti Pattern

Granting `tabledata * = RIMD` (or any wildcard with I, M, or D) in a permission set. This bypasses any meaningful separation of duties the extension could enforce and gives unreviewed code paths the ability to insert, modify, and delete on any table.

See sample: `follow-least-privilege-in-permission-sets.bad.al`.

