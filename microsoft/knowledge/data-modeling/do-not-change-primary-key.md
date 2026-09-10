---
bc-version: [all]
domain: data-modeling
keywords: [primary-key, clustered-key, table-design, appsource, breaking-change, schema-upgrade]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Never Change a Published Table's Primary or Clustered Key Field List

> Contributions welcome — open a PR to refine or extend this article.

## Description

Once a table has shipped — to AppSource, or to any customer environment that has already upgraded onto it — its primary key, and any other key marked `Clustered = true`, is frozen. This includes adding a field to the key, not only removing or reordering one: Business Central identifies existing rows by their key value, so any change to which fields compose that key invalidates every row already stored under the old shape, and the platform's upgrade validation rejects it outright (`AS0009`). This is easy to trip over because it doesn't look like the well-known "don't delete a field" mistake — the field being added is often brand new, and folding a new discriminating dimension straight into the existing key feels like the natural, un-denormalized way to model it. On an unpublished table that is correct; on a published one it is a breaking schema change regardless of which direction the field list changed, and there is no in-place fix once the upgrade is rejected, only reverting the key to its published shape.

## Best Practice

Leave a published table's key exactly as shipped. Model a new discriminating dimension as a separate table with its own key instead of adding a field to the existing key, and branch orchestration code by the new dimension rather than filtering one shared table on an extra key field.

See sample: `do-not-change-primary-key.good.al`.

## Anti Pattern

Adding a field to a published table's primary or clustered key to distinguish a new case. This fails AppSource validation or any customer upgrade with `AS0009` as soon as rows already exist under the old key shape, whether the field is being added, removed, or reordered.

See sample: `do-not-change-primary-key.bad.al`.
