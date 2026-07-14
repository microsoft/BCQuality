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

Deleting or renaming a published procedure (or object) in a single release is a hard break: dependent extensions that reference it stop compiling the moment they pick up the new version, with no warning window to migrate. AL provides staged deprecation so consumers get advance notice. A procedure uses `[Obsolete('reason', 'tag')]`: it remains callable but callers receive a compiler warning naming the replacement and the version in which obsoletion began. Methods do not have `ObsoleteState`; after the deprecation window, the method is deleted, commonly through versioned preprocessor cleanup. Objects and fields instead use the `ObsoleteState = Pending` to `Removed` property progression.

## Best Practice

When a published procedure is superseded, keep it in place and mark it `[Obsolete('Use CalculateNetAmount instead.', '25.0')]`, where the message names the replacement and the tag records when the method became obsolete. Have the obsolete member forward to the new one so behavior is preserved during the window. Only after the deprecation window has elapsed should a later release delete the method. For an object or field, use `Pending` during the warning window and `Removed` afterward.

See sample: `deprecate-public-members-with-the-obsolete-lifecycle.good.al`.

## Anti Pattern

Renaming or deleting the published `CalcNet` procedure in place — replacing it with `CalculateNetAmount` and nothing else — so consumers calling `CalcNet` break immediately with no deprecation notice. Detection: a previously shipped non-`local` procedure that vanished or was renamed between versions with no `[Obsolete]` marker left behind during a prior warning window. Do not suggest `ObsoleteState = Removed` for a method; that property belongs to supported object and element types.

See sample: `deprecate-public-members-with-the-obsolete-lifecycle.bad.al`.
