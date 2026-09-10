---
bc-version: [all]
domain: appsource
keywords: [version, release, app-json, semver, al-go, appsource]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Update the app version at every release

## Description

At every release — a branch merged to `main`, a tagged release build, or an AppSource submission — the app's version is consciously updated, not left to the pipeline alone.

| Version part | Owner | When |
|---|---|---|
| Major | Developer decision | Breaking change (schema, API, removed objects) |
| Minor | Developer decision | Every release with new functionality |
| Build / Revision | AL-Go pipeline | Automatic — never hand-edited |

The version number is the only identity a deployed app has. Two customer environments running "the same" version with different code is an undiagnosable support case. AppSource's actual requirement is strict full-version ordering — the complete version must be greater than the previously submitted version — which an AL-Go-generated build/revision increment can satisfy on its own; AppSource does not require major.minor itself to change. Treating major.minor as a deliberate, human-decided compatibility signal is still valuable practice — it is a statement about what changed that no pipeline can make on its own — just not a platform-enforced requirement.

## Best Practice

    Before the release merge:
      app.json:       "version": "1.3.0.0"    (new functionality -> minor bump, by team convention)
      AL-Go settings: "repoVersion": "1.3"     (where used)
    Then: feature branch -> main via PR, tag, release.

"Feature branches never touch the version" and "every merge to main is a release" are workflow choices your team can adopt for compatibility clarity — not something AppSource itself requires.

## Anti Pattern

    Branch merged to main and released.
    app.json still says "version": "1.2.0.0" -- same as the previous release.
    Two different code states now share one version identity.
