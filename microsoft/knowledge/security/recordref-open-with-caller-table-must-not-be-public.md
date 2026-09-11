---
bc-version: [all]
domain: security
keywords: [recordref, open, public, system-table, scope-onprem, confused-deputy, saas]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Procedures that RecordRef.Open a caller-provided table must not be public

## Description

When a codeunit holds permission to system tables — directly, via a permission set granted at install, or via `[InherentPermissions]` — and exposes a public procedure that accepts a table number (or a `RecordId`, from which the table number is derived) and calls `RecordRef.Open` on it, the procedure becomes a confused deputy. Any other extension on the same tenant can invoke the procedure with the table number of a system table the calling extension does not own permissions for and obtain access to its rows through the wrapper. This is especially acute in SaaS: an on-premises-style extension that holds broad permissions can be exploited by a co-tenant extension that calls its public surface.

## Best Practice

Mark such procedures `local` (callable only inside the containing object), `internal` (callable only inside the owning extension), or `[Scope('OnPrem')]` (not callable from SaaS extensions). If the procedure must be public, validate the table number against an allow-list before `RecordRef.Open` — `if not IsAllowedTable(RecId.TableNo) then Error(...)` — so the caller cannot specify an arbitrary table. See sample: [`recordref-open-with-caller-table-must-not-be-public.good.al`](recordref-open-with-caller-table-must-not-be-public.good.al).

## Anti Pattern

`procedure ArchiveRecord(RecId: RecordId)` (public by default) whose body calls `RecRef.Open(RecId.TableNo)` and then reads, modifies, or deletes the record. Reviewers should flag any procedure that is public (no `local`/`internal`/`[Scope('OnPrem')]`), takes a `RecordId`, `Integer` table number, or `Variant` as a parameter, and calls `RecordRef.Open` with that parameter — unless an allow-list check on the table number precedes the open. See sample: [`recordref-open-with-caller-table-must-not-be-public.bad.al`](recordref-open-with-caller-table-must-not-be-public.bad.al).
