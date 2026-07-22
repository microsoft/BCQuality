---
bc-version: [24, 25, 26, 27, 28]
domain: architecture
keywords: [ai, llm, copilot, eval, ai-test-toolkit, evaluation, testing, accuracy, token-consumption]
technologies: [al]
countries: [w1]
application-area: [all]
---

## Description

Before building a custom AL test harness to evaluate an LLM-based feature's
output quality — Copilot-style document parsing, chat, extraction, or any
capability that calls an LLM and needs a reproducible accuracy measure —
check whether Microsoft's BCApps **AI Test Toolkit** (`src/Tools/AI Test
Toolkit/` in microsoft/BCApps, starting at codeunit 149044 "AIT Test
Context") already covers the need.

## Why

The toolkit is a thin, model-agnostic wrapper: `GetInput()`,
`GetExpectedData()`, `SetTestOutput()`, `SetAccuracy()`,
`SetTokenConsumption()`. It does not call any LLM itself — your own test
codeunit calls whatever model you use (Azure OpenAI, Anthropic Claude,
anything) and reports the result back through the harness. Its only
dependencies are System Application and Test Runner — no Azure OpenAI
binding, no Copilot-specific requirement.

Adopting it gives you, for free:
- A standard `.jsonl` dataset format (`input` + `expected_output` per line)
- Built-in accuracy and token-consumption metrics per test case
- A results page inside Business Central itself, instead of a bespoke one

What it does NOT give you: the actual evaluation logic. You still write
100% of the comparison/assertion code that calls your feature and checks
its output against the expected result. The toolkit saves scaffolding, not
engineering effort — adopting it is close to free, so the bar for skipping
it should be high.

## Rule

Before building a custom AL test harness for evaluating an LLM-based
feature's output quality, check whether AI Test Toolkit already provides
it. Skip it only with a documented reason (e.g. a genuine feature gap in
the toolkit for your use case) — not merely because it is unfamiliar.

## Verified 2026-07-22

Source-level inspection of AI Test Toolkit v28.0.46665.48704 (extracted
from a local BC sandbox artifacts cache) confirmed the claims above. Two
commonly-assumed capabilities were checked and NOT found in the toolkit's
actual AL source: an Azure-AI-Foundry-based "Red Team Scan," and any
Azure-OpenAI-specific binding. Do not assume either exists without
re-verifying against the version you target — BCApps evolves.
