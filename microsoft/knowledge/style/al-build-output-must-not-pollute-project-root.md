---
bc-version: [all]
domain: style
keywords: [build, output, alpackages, artifact-hygiene, outfolder, project-root]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Write AL Build Artifacts to an Intentional Output Location

> Contributions welcome — open a PR to refine or extend this article.

## Description

An AL project's compiled `.app` file can be written to the project root by default, and current tooling explicitly supports choosing a different destination instead — `ALTool`'s `--outfolder` option and the `al_build` agent tool's `outputPath` parameter both exist for this. The problem this rule addresses is not that root-level output is technically invalid; it is agents leaving generated `.app` files scattered through arbitrary source locations, or treating a compiled artefact as if it were part of the source tree (committing it, editing around it, referencing it as a dependency by hand).

## Best Practice

Write build artifacts to a deliberate, dedicated output location — configured via the build tool actually in use (e.g. `ALTool --outfolder`, or an explicit `outputPath` on the agent build tool) — and add that folder to `.gitignore`. Treat a compiled `.app` as a build artifact, never as a source file to commit or hand-edit around.

## Anti Pattern

Letting `.app` files accumulate in arbitrary or unversioned locations without a deliberate output path, or committing compiled artefacts into source control alongside the AL files that produced them.
