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

The version number is the only identity a deployed app has. Two customer environments running "the same" version with different code is an undiagnosable support case; an AppSource submission with an unchanged major.minor is a rejected submission. AL-Go increments build numbers on every CI run, which creates the illusion that versioning is handled — but major.minor is a human statement about compatibility, and no pipeline can make it.

## Best Practice

    Before the release merge:
      app.json:       "version": "1.3.0.0"    (new functionality -> minor bump)
      AL-Go settings: "repoVersion": "1.3"     (where used)
    Then: feature branch -> main via PR, tag, release.

Feature branches never touch the version; only the release does.

## Anti Pattern

    Branch merged to main and released.
    app.json still says "version": "1.2.0.0" -- same as the previous release.
    Two different code states now share one version identity.
