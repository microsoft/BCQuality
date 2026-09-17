<!-- guard:new-top-level -->
👋 Heads up @{{AUTHOR}} — and cc maintainers — this PR introduces **new top-level entries** that aren't part of BCQuality's known repository structure:

{{ENTRIES}}

This isn't a block — just a flag. 🚩 New top-level folders and files are *usually* unintended (a stray export, a tool's scratch dir, or content that meant to land inside an existing layer). BCQuality keeps a deliberately small root: plugin metadata, `community/`, `custom/`, `microsoft/`, `skills/`, `tools/`, `docs/`, `evaluation/`, `.github/`, and a handful of root docs. Partner guides belong under `docs/`; shared knowledge belongs beside the skill that owns its domain.

**If this was intentional** and the new entry genuinely belongs at the repo root, a maintainer can review and merge as normal — no action needed beyond a quick sanity check. **If it wasn't**, please move the content into the right existing layer (or drop it) and push an update. 🙏

A maintainer will take a look before merging.
