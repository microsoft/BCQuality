---
bc-version: [all]
domain: breaking-changes
keywords: [released-baseline, unreleased, rename, renumber, obsolete, api-stability, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Changing an unreleased symbol is not a breaking change

## Description

Breaking-change rules protect contracts that have already shipped to customers or are exposed to external extensions. A symbol — an object, field, key, enum value, or procedure — that is new in this app, was introduced and then changed within the same still-unreleased development cycle, or belongs to an app that has no released version yet, can be renamed, renumbered, or removed freely. There is no shipped contract to break, so the change is not a breaking change.

Release status is established from the diff, the app's `app.json` version, or a released baseline. An app whose `app.json` version has no corresponding released baseline (for example a `1.0.0.0` app that has never shipped) has no protected surface.

## Best Practice

Before treating a rename, renumber, or removal as breaking, establish that the affected symbol was present in a released baseline. Do not flag changes to symbols that are new in the current unreleased cycle or that belong to an app with no released version. When release status cannot be established from the diff, `app.json`, or a released baseline, omit the finding rather than assert a break.

## Anti Pattern

Reporting a breaking change for a rename, renumber, or removal without confirming the symbol shipped in a released version — for example flagging a break on an app whose `app.json` version has no released baseline.
