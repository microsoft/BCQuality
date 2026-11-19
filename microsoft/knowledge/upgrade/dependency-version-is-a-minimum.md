---
bc-version: [all]
domain: upgrade
keywords: [app-json, dependencies, minimum-version, dependency-version, symbols, manifest, compatibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# The `version` of a dependency in `app.json` is a minimum

## Description

Each entry in the `dependencies` list of `app.json` names another extension by `id`, `name`, `publisher`, and `version`. The version does not pin the dependency. It defines the minimum version: at run time and when downloading symbols, the latest version of the dependency that satisfies the name, publisher, and minimum version is returned. The same reading applies to `application` and `platform`, which state minimum versions of the Application package and the System symbols.

Two consequences follow. The extension can be installed alongside any later version of the dependency, so it does not control which version it actually runs against. And the symbols a developer compiles against are usually newer than the declared minimum, so the code can use a member that the declared minimum version does not contain.

## Best Practice

Declare the lowest dependency version whose public surface the extension really uses, and raise it in the same change that starts using a member introduced in a later version. Treat the declared value as a statement of what the extension requires, not as a record of what was installed on the development environment.

Do not rely on a dependency staying at the declared version. Behavior that must hold across dependency versions belongs in tests against the versions the extension claims to support.

## Anti Pattern

Leaving the dependency version at its original value while adopting procedures, events, or fields that the dependency added later. The project compiles against current symbols, and the manifest still claims compatibility with a version that lacks those members, so the mismatch surfaces only on an environment that has the older dependency.

A second form is reading the version as exact: reporting a dependency as outdated or mismatched because a newer version exists, or expecting the declared version to be the one that is loaded.

## References

The `dependencies`, `application`, and `platform` settings in [JSON files](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-json-files#appjson-file) and [Choose runtime version in AL](https://learn.microsoft.com/dynamics365/business-central/dev-itpro/developer/devenv-choosing-runtime).
