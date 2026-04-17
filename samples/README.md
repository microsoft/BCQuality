# BCQuality Samples

This directory contains AL (and, over time, other-language) code samples referenced by knowledge articles in BCQuality.

## Layout

Samples are organized by domain and by the slug of the knowledge article that references them:

```
samples/
  <domain>/
    <article-slug>/
      bad.al      # demonstrates the anti-pattern
      good.al     # demonstrates the best practice
```

Some articles only have a `good.al` (best practice only) or only a `bad.al` (pure avoidance). That is intentional.

## Status

All samples are **demonstration-only**. They are self-contained AL objects with object IDs in the 50100-50199 range and are not meant to be deployed, nor are they derived from Microsoft's Business Central base application source. They exist to make the accompanying knowledge articles concrete for human readers and for agents that benefit from a worked example.

## Referencing samples from knowledge articles

Knowledge articles MUST NOT contain fenced code blocks (see `skills/read.md`). When a knowledge article wants to show code, it references the relevant sample by path, for example:

> See sample: `samples/performance/filter-before-find/good.al`.

Orchestrators and action skills are free to read these files and include relevant excerpts in their output.
