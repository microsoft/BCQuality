---
bc-version: [all]
domain: ui
keywords: [style, cuegroup, cue-tile, favorable, unfavorable, accessibility]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Semantic styles in a cuegroup are auto-labeled

## Description

Fields inside a `cuegroup` render as cue tiles. The Business Central client automatically provides an accessible label for semantic styles on cue tiles (for example, "Favorable", "Unfavorable"). Semantic styles in a `cuegroup` therefore do **not** need additional context and should be ignored when checking that semantic colors are backed by text.

This is a narrow platform exception to `semantic-styles-need-independent-textual-meaning.md`. Outside a `cuegroup`, the normal rule applies.

## Best Practice

You may apply `Favorable`, `Unfavorable`, or `Ambiguous` to fields inside a `cuegroup` without supplying a redundant textual indicator — the platform supplies the screen-reader text. Reserve this shortcut for cue tiles only; do not extend it to other layout containers.

See sample: [`semantic-style-in-cuegroup-exception.good.al`](semantic-style-in-cuegroup-exception.good.al).
