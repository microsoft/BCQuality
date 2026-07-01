---
bc-version: [all]
domain: appsource
keywords: [object-affix, prefix, suffix, as0011, appsourcecop, collision, tableextension]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Apply a reserved affix to objects and to members added to base objects

## Description

An AppSource extension must carry a reserved affix — a prefix or a suffix of at least three characters — on the names of the objects it owns **and** on any field, key, control, or action it adds to a base-application object. The affix is registered with Microsoft; when two coexisting extensions would otherwise collide, the registrant of the affix wins. Without it, two apps that both add a `Loyalty Points` field to `Customer`, or both define a `Loyalty Tier` table, cannot be installed side by side.

AppSourceCop enforces this. The primary rule is AS0011 ("An affix is required"); the affixes are configured through `mandatoryAffixes` (and `mandatoryPrefix`) in `AppSourceCop.json`. Two placements matter and are easy to get half-right: an object you define carries the affix at **object-name** level, while a member you add to a **standard** object carries the affix on that **member's** name. Adding an affixed object is not enough — an unaffixed field bolted onto `Customer` still collides and still fails validation.

## Best Practice

Own objects are named with the affix (e.g. a table `ABC Loyalty Tier`), and every field or action added to a standard object is individually affixed (e.g. `Loyalty Points ABC` on a `Customer` tableextension).

See sample: `object-affixes-prevent-collisions.good.al`.

## Anti Pattern

Unaffixed object or member names, or the common half-measure: the extension object carries the affix but a field it adds to a standard table does not. AS0011 flags the missing affix and the field can still collide with another app.

See sample: `object-affixes-prevent-collisions.bad.al`.
