---
bc-version: [all]
domain: style
keywords: [build, output, alpackages, duplicate, language-server, app-package, project-root, al0197]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Keep AL Build Output Out of the Project Root

> Contributions welcome — open a PR to refine or extend this article.

## Description

When an AL project is built, the compiled `.app` file is placed in the project root by default. Over successive builds, multiple `.app` files accumulate there (e.g. one per version). The AL language server, both in the editor and in build tooling, scans the project folder for symbol packages and can load these compiled artefacts alongside the live source files, which produces `AL0197` duplicate-object errors for every object in the project — with messages that point at source lines rather than at the packaged artefact that is the actual duplicate. The errors are not real; they disappear as soon as the stale `.app` files are removed from the root.

## Best Practice

Configure the build output path to a dedicated subfolder that is excluded from language server scanning — for example by setting `al.outputPath` to a folder such as `.output` in `.vscode/settings.json`, or by passing an explicit output path to the build tool being used — and add that folder to `.gitignore`. Before treating an `AL0197` "already declared" error as a source code problem, check the project root for stale `.app` files first; adding root `.app` files to `.gitignore` instead of relocating the output path only hides the accumulation rather than fixing it.

## Anti Pattern

Letting `.app` files accumulate in the project root across builds, then debugging the resulting `AL0197` duplicate-object errors as if they were a source code defect instead of first checking for stale build artefacts in the root folder.
