---
bc-version: [all]
domain: breaking-changes
keywords: [obsolete, deprecation, obsoletestate, obsoletetag, pending, removed, public-procedure]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Deprecate public members through the Obsolete lifecycle, never delete them outright

## Description

Deleting or renaming a published procedure (or object) in a single release is a hard break: dependent extensions that reference it stop compiling the moment they pick up the new version, with no warning window to migrate. AL provides a staged deprecation lifecycle precisely so consumers get advance notice. For a procedure, apply the `[Obsolete('reason', 'tag')]` attribute: the member keeps working but every caller gets a compiler warning naming the replacement and the target version. The member stays through a deprecation window — at least one major release — before it is finally removed. Object- and field-level members use the matching `ObsoleteState = Pending` → `Removed` property progression. LLMs trained to "clean up" code often delete or rename the old member immediately, skipping the window entirely.

## Best Practice

When a published procedure is superseded, keep it in place and mark it `[Obsolete('Use CalculateNetAmount instead.', '25.0')]`, where the message names the replacement and the tag records the target version for removal. Have the obsolete member forward to the new one so behavior is preserved during the window. Only after the deprecation window has elapsed — a later release — change its state to removed. This gives every dependent app a compile-time signal and time to migrate before anything actually disappears.

See sample: `deprecate-public-members-with-the-obsolete-lifecycle.good.al`.

## Anti Pattern

Renaming or deleting the published `CalcNet` procedure in place — replacing it with `CalculateNetAmount` and nothing else — so consumers calling `CalcNet` break immediately with no deprecation notice. Detection: a previously shipped non-`local` procedure that vanished or was renamed between versions with no `[Obsolete]` marker left behind on a kept member. Mark it obsolete and keep it for a window instead.

See sample: `deprecate-public-members-with-the-obsolete-lifecycle.bad.al`.
