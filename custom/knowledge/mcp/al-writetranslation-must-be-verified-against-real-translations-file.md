---
bc-version: [all]
domain: mcp
keywords: [al-mcp, al_writetranslation, al_searchtranslations, xliff, translation, silent-failure, wrong-path]
technologies: [al]
countries: [w1]
application-area: [all]
---

# al_writetranslation/al_searchtranslations must be verified against the real Translations/ file

## Description

The `al` MCP server's `al_writetranslation` and `al_searchtranslations` tools
expose no `projectPath`/`appPath` parameter — unlike `al_build`/`al_publish`,
there is no way to tell them explicitly which project's `Translations/`
folder to target. When called for the current project's own (non-dependency)
strings, they can resolve to the wrong location silently: `al_writetranslation`
may create a brand-new, wrong-path `Translations/` subfolder — populated with
placeholder `<source>(source)</source>` entries instead of the real source
text — rather than updating the actual `<AppFolder>/Translations/<AppName>.
<locale>.xlf` file. `al_searchtranslations` can likewise return zero results
for a project's own strings even when they unambiguously exist in the real
file, while correctly returning results for a named dependency app (e.g.
`appName: "Base Application"`).

Both tools report success (`"success": true"`, `"fileCreated": ...`) in this
failure mode — there is no error to catch. A developer trusting the response
alone will believe a batch of translations landed when none of them did,
while a spurious extra `Translations/` folder appears elsewhere in the app
under source control (`git status` shows it as a new untracked path once
tracked/added).

## Why

This is a more dangerous failure mode than a relative-path error on
`al_build`/`al_publish` (see `al-mcp-build-publish-projectpath-must-be-
absolute.md`): that one fails loudly with "Invalid URI". This one fails
silently with a success response, and the tool gives the agent no parameter
to fix the targeting even after the mismatch is noticed.

## How to apply

After any `al_writetranslation` call against the current project's own
strings, verify the write landed in the real file before reporting the
translation as done:

1. Read (or grep) `<AppFolder>/Translations/<AppName>.<locale>.xlf` directly
   for the exact `trans-unit id` just written.
2. Confirm its `<target state="translated">` contains the expected text —
   not a placeholder, and not absent.
3. If the file was not updated, do not retry the same tool call expecting a
   different result — fall back to editing the XLIFF file(s) directly (a
   direct string/XML edit, verified with an XML parser afterward, is
   reliable) rather than trusting `al_writetranslation` for the remainder of
   the batch.
4. If a spurious `Translations/` folder appeared anywhere else in the app
   during this process, remove it before continuing — it is dead output,
   not a legitimate translation source.

`al_searchtranslations` is reliable for looking up **dependency** app
translations (pass `appName`) to check established terminology — the gap is
specific to a project's own strings.

## What NOT to do

- Do not trust a `"success": true` response from `al_writetranslation` for
  a project's own translations without checking the real target file.
- Do not repeat the same `al_writetranslation` call hoping a different
  outcome — the tool has no path-correction parameter to supply.
- Do not leave a spurious `Translations/` folder it created lying around
  under source control.

## Applies to

All CURABIS projects using the `al` MCP server for translation work (any
repo with the standard `al` entry, machine-global per the v24 CURABIS
Standard) that ship XLIFF translation files.
