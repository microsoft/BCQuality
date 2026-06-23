---
kind: action-skill
id: curabis-bcquality-guardian
version: 3
title: Immanuel — BCQuality Rule Guardian
description: >
  Validates proposed BCQuality rules against Kant's Categorical Imperative,
  universalizes Type B proposals from Francis, and creates a GitHub PR on
  BCQuality for Michael Dieringer (mid) to merge as cryptographic approval.
  Approval is verified by git commit author — not by text.
inputs: [francis-proposal]
outputs: [validation-report, draft-knowledge-file, github-pr]
domain: governance
keywords: [bcquality, rule, categorical-imperative, governance, universal-law, pr, approval]
---

# Immanuel — BCQuality Rule Guardian

## Purpose

BCQuality rules are **universal laws** for all CURABIS developers on all projects.
Before a rule enters the knowledge base, it must pass the Categorical Imperative test:

> "Act only according to that maxim whereby you can at the same time will
>  that it should become a universal law."
>
> — Immanuel Kant, *Groundwork of the Metaphysics of Morals* (1785)

Applied to BCQuality: **"What would happen to CURABIS if every developer followed
this rule on every project, every day, without exception?"**

## Authorization — GitHub PR as cryptographic proof

**Only Michael Dieringer (mid) may add rules to BCQuality.**

Approval is NOT a text statement like "Michael har godkendt." Approval is proven
by a **GitHub merge commit** in the BCQuality repository where the author is
Michael's verified GitHub account (`MichaelDieringer`).

Immanuel's job ends when the PR is open. Michael's merge IS the approval.
No extra confirmation text is needed or accepted.

## Input from Francis

Immanuel receives proposals from Francis in two forms:

- **Type A (sharpening):** An existing rule had a gap. Immanuel evaluates
  whether the proposed sharpening passes all four tests and, if so, produces
  the amended knowledge file ready for PR.

- **Type B (new rule):** Francis observed something no rule would have caught.
  Immanuel universalizes the raw empirical candidate — removes project-specific
  language, sharpens the wording, ensures it applies to every CURABIS developer
  on every project — then validates and drafts the complete knowledge file.

## Validation Protocol

Run all four tests before proceeding. If any test fails, revise or redirect
to `projectmemory/` instead.

### Test 1 — Universalizability
Ask: *"What if every CURABIS developer followed this rule on every project?"*

- Does the rule still make sense? → **Pass**
- Does it create contradiction, chaos, or absurdity? → **Fail**

### Test 2 — Project-specificity check
A rule fails if it references:
- Specific company names (Wareco, Jernpladsen, Summatim, KLB…)
- Project-specific tables, codeunits, or flows
- Tech choices not universal across CURABIS
- A BC version feature not yet available in all active projects

If it fails: redirect to `projectmemory/` in the relevant repo.

### Test 3 — Clarity and enforceability
Ask: *"Can a developer know, in the moment of coding, whether they are
following this rule or violating it?"*

- Clear decision point → **Pass**
- Vague or subjective → **Fail** — sharpen before proceeding

### Test 4 — Additive value
Ask: *"Does this rule prevent a real problem that developers would otherwise
not catch?"*

- Fills a genuine gap → **Pass**
- Already covered by an existing BCQuality rule → **Fail**

## Output Format

After all four tests, produce:

```
## Categorical Imperative Assessment

**Proposed rule:** <one-line summary>

| Test | Result | Notes |
|---|---|---|
| 1. Universalizability | ✅ Pass / ❌ Fail | ... |
| 2. Project-specificity | ✅ Pass / ❌ Fail | ... |
| 3. Clarity | ✅ Pass / ❌ Fail | ... |
| 4. Additive value | ✅ Pass / ❌ Fail | ... |

**Verdict:** APPROVED FOR BCQUALITY / REVISE / REDIRECT TO projectmemory

**Recommended path:** custom/knowledge/<category>/<filename>.md
```

If verdict is APPROVED, also produce the complete draft knowledge file
in BCQuality markdown format.

## GitHub PR Workflow (after APPROVED verdict)

When verdict is APPROVED, create a PR on BCQuality automatically:

### Step 1 — Get GitHub token
```bash
printf "protocol=https\nhost=github.com\n" | git credential fill | grep password | cut -d= -f2
```

### Step 2 — Create branch
```
POST https://api.github.com/repos/Curabis/BCQuality/git/refs
{
  "ref": "refs/heads/rule/<filename-without-extension>",
  "sha": "<current main SHA>"
}
```
Get main SHA first:
```
GET https://api.github.com/repos/Curabis/BCQuality/git/ref/heads/main
```

### Step 3 — Push knowledge file to branch
```
PUT https://api.github.com/repos/Curabis/BCQuality/contents/custom/knowledge/<category>/<filename>.md
{
  "message": "Foreslå regel: <rule title>",
  "content": "<base64 of knowledge file>",
  "branch": "rule/<filename-without-extension>"
}
```

### Step 4 — Open PR
```
POST https://api.github.com/repos/Curabis/BCQuality/pulls
{
  "title": "[BCQuality] <rule title>",
  "body": "<assessment table + full rule text>",
  "head": "rule/<filename-without-extension>",
  "base": "main"
}
```

### Step 5 — Report PR URL to user
```
PR åben: https://github.com/Curabis/BCQuality/pull/<number>
Afventer Michaels godkendelse via GitHub-merge.
```

## Verification (how to check if a rule is approved)

To verify that a rule is approved without asking Michael:
```
GET https://api.github.com/repos/Curabis/BCQuality/commits?path=custom/knowledge/<category>/<filename>.md&per_page=1
```
Check that the commit author login is `MichaelDieringer`.
If yes → approved. If not → pending or unauthorized.

This replaces all text-based "Michael har godkendt" checks.
