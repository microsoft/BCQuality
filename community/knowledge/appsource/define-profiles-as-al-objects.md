---
bc-version: [all]
domain: appsource
keywords: [profile-object, profile-table, install-codeunit, role-center, page-customization]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Define profiles as AL objects

## Description

Profiles delivered by an AppSource extension must be declared as AL `profile` objects. A profile object is validated with its Role Center and page customizations when the extension is compiled and is registered through extension synchronization. Inserting profile-table records from install or setup code bypasses that object lifecycle.

## Best Practice

Declare each app-owned profile with the `profile` object and set its `RoleCenter`, user-facing caption, and optional customizations in AL. Let installation and synchronization register the object.

See sample: `define-profiles-as-al-objects.good.al`.

## Anti Pattern

Install, upgrade, or setup code that creates an app-owned profile by inserting a `Profile` table record. Detection signal: a `Record Profile` variable followed by `Insert` in profile provisioning code.

See sample: `define-profiles-as-al-objects.bad.al`.