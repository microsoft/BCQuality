# Exposed objects must be in at least one permission set

**Rule (CURABIS-ARCH-011):** Every *exposed* object in a CURABIS app must be a member of
at least one permission set shipped by that app. "Exposed" means any object reachable from
outside the app's own UI:

- API pages (`PageType = API`)
- Web-service-enabled pages and queries (`ServiceEnabled = true`, published web services)
- API queries

## Why

An exposed object that is in no permission set is **unusable and invisible** to the users
and service identities that are supposed to call it. This is exactly how the MCP API pages
(`CUR MCP Projects`, `CUR MCP Active Tasks`, `CUR MCP Task Comments`) failed: the tables
behind them were granted, but the pages themselves had no `= X` execute permission, so the
MCP server could not see or call them.

It is also a **governance gap**: an endpoint that nobody deliberately put in a permission
set is an endpoint nobody is deciding who may reach. Exposure must be an explicit choice.

## How to apply

1. For every exposed object, add an execute entry (`page "..." = X`, `query "..." = X`) to
   a permission set in the app.
2. **Sensitive endpoints go in a dedicated admin permission set** (e.g. `CUR ... Admin`)
   that is *not* part of the default assignable set — so reaching them is a deliberate grant,
   not the default.
3. If an object should not be reachable from outside at all, **remove the exposure** instead
   (drop `PageType = API` / `ServiceEnabled`) rather than leaving an orphaned endpoint.

## How to check

Scan the app for exposed objects and verify each is referenced in a permission set:

- find every `PageType = API`, `ServiceEnabled = true`, and API query
- confirm each appears as a `page`/`query` `= X` entry in at least one `permissionset`
- flag any exposed object with no permission-set membership

A reviewer (or an automated check) should fail the change if an exposed object is missing
from every permission set.
