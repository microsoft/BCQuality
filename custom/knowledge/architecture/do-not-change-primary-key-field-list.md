---
bc-version: [all]
domain: architecture
keywords: [primary-key, clustered-key, table-design, appsource, breaking-change, schema-upgrade]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Never change a published table's primary/clustered key field list

## Description

Once a table has shipped — to AppSource, or to any customer who has upgraded
onto it — its primary key (and any other `Clustered = true` key) is frozen.
This includes adding a field to the key, not only removing or reordering
one: Business Central identifies existing rows by their key value, and any
change to which fields compose that key invalidates every row already
stored under the old key shape. The platform's own upgrade validation
rejects this outright (`AS0009`), and it fails identically whether the
target is a real AppSource submission or a plain extension upgrade on any
environment that already has the table installed with data.

This is easy to trip over because it doesn't look like the well-known
"don't delete a field" mistake: the field being added to the key is often
brand new, and the temptation is to fold a new discriminating dimension
(a type, a flow, a category) straight into the existing key because that is
the natural, un-denormalized way to model it. On an unpublished table that
is correct. On a published one, it is a breaking schema change regardless
of which direction the field list changed.

## Why

A key is not just an index — it is the table's identity contract with every
row already stored under it, and with every dependent extension that reads
or writes through `Get()` calls shaped by that key. Changing its field list
means BC can no longer say "this stored row is the same logical record it
was before the upgrade," so it refuses the upgrade rather than silently
losing or duplicating data. There is no in-place fix once this state is
reached — the only way out is reverting the key to its published shape.

## Anti Pattern

    // Table already shipped with:
    //   key(PK; "Period Start") { Clustered = true; }
    //
    // "Just add a field to distinguish the two flows" —
    field(2; Flow; Enum "Some Flow Enum") { }
    keys
    {
        key(PK; Flow, "Period Start") { Clustered = true; }
    }
    // AS0009 on next AppSource validation or extension upgrade:
    // "Ændring af felter for nøglen 'PK' er ikke tilladt."

## Best Practice

    // Leave the published table's key exactly as shipped:
    //   key(PK; "Period Start") { Clustered = true; }
    //
    // Model the new dimension as a new, separate table instead —
    // mirroring the published one's shape, with its own key:
    table 50101 "New Flow Stats"
    {
        keys
        {
            key(PK; "Period Start") { Clustered = true; }
        }
    }
    // The published table's schema and public procedures never change.
    // Orchestration code branches by flow to the matching table instead
    // of filtering one shared table by an extra key field.

## Scope

All CURABIS apps once a table has been published — AppSource apps from
their first submission onward, customer apps from their first
customer-environment deployment onward. Does not apply to a table
introduced in the same, still-unreleased change set — a genuinely new table
can define its key however it needs to; the constraint begins at
publication, not at table creation.
