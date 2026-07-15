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

An AppSource extension must prevent name collisions through its registered affix or, on BC23 and later for objects it owns, a namespace with at least two levels. The affix still applies to every field, key, control, or action added to a base-application object; see `two-level-namespace-replaces-object-affix-not-extension-member-affix.md`. Without either mechanism, two apps that both define a `Loyalty Tier` table cannot coexist, and two apps that add an unaffixed `Loyalty Points` field to `Customer` still collide regardless of their namespaces.

AppSourceCop enforces this. The primary rule is AS0011 ("An affix is required"); the affixes are configured through `mandatoryAffixes` (and `mandatoryPrefix`) in `AppSourceCop.json`. Two placements matter and are easy to get half-right: an object you define carries the affix at **object-name** level, while a member you add to a **standard** object carries the affix on that **member's** name. Adding an affixed object is not enough — an unaffixed field bolted onto `Customer` still collides and still fails validation.

## Best Practice

Own objects use the registered affix (for example `ABC Loyalty Tier`) or, when targeting BC23 or later, a qualifying namespace. Every field or action added to a standard object remains individually affixed (for example `Loyalty Points ABC` on a `Customer` tableextension).

See sample: `object-affixes-prevent-collisions.good.al`.

## Anti Pattern

An owned object with neither a qualifying namespace nor an affix, an unaffixed extension member, or the common half-measure where the extension object carries the affix but a field it adds to a standard table does not. AS0011 flags the missing collision protection and the field can still collide with another app.

See sample: `object-affixes-prevent-collisions.bad.al`.
