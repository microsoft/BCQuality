#!/usr/bin/env python3
"""
Reference implementation of the bc-domain-context action skill.

Executes the skill's Source -> Relevance -> Worklist -> Action pipeline against
a BCQuality repository root and returns a findings-report dict conforming to
the DO output contract.

This module is the *spec by example* for consumers that reimplement the skill
in other languages (for example, the Triage agent's Node.js client). Tests in
.github/scripts/tests/test_bc_domain_context.py exercise this implementation
against fixture knowledge trees.

Usage (from Python):
    from bc_domain_context import run_bc_domain_context
    report = run_bc_domain_context(repo_root, task_context)

Skill behaviour is defined in microsoft/skills/bc-domain-context.md; READ's
frontmatter-matching semantics live in skills/read.md.
"""
from __future__ import annotations

import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any, Iterable

try:
    import yaml
except ImportError:
    sys.stderr.write("ERROR: PyYAML is required. Install with: pip install pyyaml\n")
    sys.exit(2)


LAYERS = ("custom", "microsoft", "community")  # highest precedence first
SKILL_ID = "bc-domain-context"
SKILL_VERSION = 1


@dataclass
class KnowledgeFile:
    path: str                      # repo-relative, forward slashes
    layer: str                     # "microsoft" | "community" | "custom"
    domain: str                    # folder name
    slug: str                      # filename stem
    frontmatter: dict[str, Any]
    title: str                     # first H1 in body, or slug if absent
    description: str               # prose after "## Description", trimmed


# --- Frontmatter + body parsing ---------------------------------------------

def _parse_markdown(text: str) -> tuple[dict[str, Any] | None, str]:
    lines = text.splitlines()
    if not lines or lines[0].rstrip() != "---":
        return None, text
    for i in range(1, len(lines)):
        if lines[i].rstrip() == "---":
            try:
                fm = yaml.safe_load("\n".join(lines[1:i])) or {}
            except yaml.YAMLError:
                return None, text
            if not isinstance(fm, dict):
                return None, text
            return fm, "\n".join(lines[i + 1:])
    return None, text


def _extract_title(body: str, fallback: str) -> str:
    for line in body.splitlines():
        m = re.match(r"^#\s+(.+?)\s*$", line)
        if m:
            return m.group(1).strip()
    return fallback


def _extract_description(body: str) -> str:
    lines = body.splitlines()
    for i, line in enumerate(lines):
        if re.match(r"^##\s+Description\s*$", line):
            buf: list[str] = []
            for j in range(i + 1, len(lines)):
                if re.match(r"^##\s+", lines[j]):
                    break
                buf.append(lines[j])
            return "\n".join(buf).strip()
    return ""


# --- bc-version expansion (matches validate_frontmatter.expand_bc_version) --

_RANGE = re.compile(r"^(\d+)\.\.(\d+)$")


def _expand_bc_version(value: Any) -> list[int] | None:
    if not isinstance(value, list) or not value:
        return None
    if all(isinstance(v, int) and not isinstance(v, bool) and v > 0 for v in value):
        return sorted(set(value))
    if len(value) == 1 and isinstance(value[0], str):
        m = _RANGE.match(value[0].strip())
        if m:
            start, end = int(m.group(1)), int(m.group(2))
            if start <= end:
                return list(range(start, end + 1))
    return None


# --- READ's frontmatter matching rules --------------------------------------

def _matches(
    kf: KnowledgeFile, task_context: dict[str, Any]
) -> tuple[bool, list[str]]:
    """Return (applicable, unknown_dimensions) per READ's semantics.

    A file is applicable when every rule matches. A rule is "unknown" when the
    task context omits a dimension and the file does not declare a universal
    sentinel for it; unknown rules do not disqualify the file but force a
    medium-confidence ceiling on derived findings.
    """
    unknown: list[str] = []
    fm = kf.frontmatter

    # bc-version
    file_versions = _expand_bc_version(fm.get("bc-version"))
    if file_versions is None:
        return False, unknown
    task_version = task_context.get("bc-version")
    if task_version is None:
        unknown.append("bc-version")
    elif task_version not in file_versions:
        return False, unknown

    # technologies (no sentinel)
    file_techs = set(fm.get("technologies") or [])
    task_techs = set(task_context.get("technologies") or [])
    if not task_techs:
        unknown.append("technologies")
    elif not (file_techs & task_techs):
        return False, unknown

    # countries (sentinel: w1)
    file_countries = set(fm.get("countries") or [])
    task_countries = set(task_context.get("countries") or [])
    if "w1" in file_countries:
        pass
    elif not task_countries:
        unknown.append("countries")
    elif not (file_countries & task_countries):
        return False, unknown

    # application-area (sentinel: all)
    file_areas = set(fm.get("application-area") or [])
    task_areas = set(task_context.get("application-area") or [])
    if "all" in file_areas:
        pass
    elif not task_areas or "all" in task_areas:
        # Empty or [all] in task means "any area"; file-level specific area
        # still matches against any-area when sourced from the area folder.
        pass
    elif not (file_areas & task_areas):
        return False, unknown

    return True, unknown


# --- Knowledge corpus load --------------------------------------------------

def _load_knowledge_file(root: Path, path: Path) -> KnowledgeFile | None:
    rel = path.relative_to(root).as_posix()
    parts = rel.split("/")
    if len(parts) != 4 or parts[1] != "knowledge":
        return None
    layer, _, domain, filename = parts
    slug = Path(filename).stem
    try:
        text = path.read_text(encoding="utf-8")
    except (OSError, UnicodeDecodeError):
        return None
    fm, body = _parse_markdown(text)
    if fm is None:
        return None
    return KnowledgeFile(
        path=rel,
        layer=layer,
        domain=domain,
        slug=slug,
        frontmatter=fm,
        title=_extract_title(body, slug),
        description=_extract_description(body),
    )


def _load_corpus(
    root: Path, enabled_layers: Iterable[str], areas: Iterable[str] | None
) -> list[KnowledgeFile]:
    """Walk <layer>/knowledge/<area>/*.md for enabled layers.

    If `areas` is None or contains "all", walk every area folder. Otherwise,
    walk only the named area folders.
    """
    enabled = set(enabled_layers) & set(LAYERS)
    area_set = None
    if areas is not None:
        areas_list = list(areas)
        if areas_list and "all" not in areas_list:
            area_set = set(areas_list)
    corpus: list[KnowledgeFile] = []
    for layer in enabled:
        knowledge_root = root / layer / "knowledge"
        if not knowledge_root.is_dir():
            continue
        for domain_dir in knowledge_root.iterdir():
            if not domain_dir.is_dir():
                continue
            if area_set is not None and domain_dir.name not in area_set:
                continue
            for md_path in domain_dir.glob("*.md"):
                kf = _load_knowledge_file(root, md_path)
                if kf is not None:
                    corpus.append(kf)
    return corpus


# --- Layer precedence -------------------------------------------------------

def _resolve_precedence(
    files: list[KnowledgeFile],
) -> tuple[list[KnowledgeFile], list[dict[str, Any]]]:
    """Keep the highest-precedence file per (domain, slug). Return (kept, suppressed).

    suppressed entries have shape { "reference": { "path": ... }, "reason": "layer-precedence" }.
    """
    precedence = {layer: i for i, layer in enumerate(LAYERS)}  # lower index = higher precedence
    groups: dict[tuple[str, str], list[KnowledgeFile]] = {}
    for f in files:
        groups.setdefault((f.domain, f.slug), []).append(f)
    kept: list[KnowledgeFile] = []
    suppressed: list[dict[str, Any]] = []
    for group in groups.values():
        group.sort(key=lambda f: precedence.get(f.layer, 99))
        kept.append(group[0])
        for loser in group[1:]:
            suppressed.append({
                "reference": {"path": loser.path},
                "reason": "layer-precedence",
            })
    return kept, suppressed


# --- Worklist narrowing -----------------------------------------------------

_GOAL_PREFIX = re.compile(r"^bc-domain-context(?:\s+for\s+[a-z0-9,\- ]+)?\s*", re.IGNORECASE)
_TOKEN = re.compile(r"[a-z0-9]+")


def _extract_goal_tokens(goal: str) -> list[str]:
    """Strip the 'bc-domain-context for <area>' prefix and return significant tokens."""
    if not goal:
        return []
    stripped = _GOAL_PREFIX.sub("", goal).strip()
    if not stripped:
        return []
    return [t for t in _TOKEN.findall(stripped.lower()) if len(t) >= 3]


def _score(kf: KnowledgeFile, tokens: list[str]) -> int:
    if not tokens:
        return 0
    kw = {k.lower() for k in (kf.frontmatter.get("keywords") or [])}
    text = f"{kf.slug} {kf.title} {kf.description}".lower()
    score = 0
    for t in tokens:
        if t in kw:
            score += 3
        if t in text:
            score += 1
    return score


def _narrow(
    kept: list[KnowledgeFile], task_context: dict[str, Any], max_top: int = 15
) -> list[KnowledgeFile]:
    tokens = _extract_goal_tokens(task_context.get("goal") or "")
    if not tokens:
        return kept
    scored = [(kf, _score(kf, tokens)) for kf in kept]
    scored.sort(key=lambda p: (-p[1], p[0].path))
    # Keep only files with positive score; fall back to full set if none score.
    positive = [kf for kf, s in scored if s > 0]
    if not positive:
        return kept
    return positive[:max_top]


# --- Message construction ---------------------------------------------------

def _message(kf: KnowledgeFile, unknown: list[str]) -> str:
    first_sentences = re.split(r"(?<=[.!?])\s+", kf.description, maxsplit=3)
    lead = " ".join(first_sentences[:3]).strip() if first_sentences else ""
    msg = f"{kf.title}. {lead}" if lead else kf.title
    if unknown:
        msg += f" (conditional on: {', '.join(sorted(unknown))})"
    return msg


# --- Main entrypoint --------------------------------------------------------

def run_bc_domain_context(
    root: Path | str, task_context: dict[str, Any]
) -> dict[str, Any]:
    """Execute the skill against the repository at `root`.

    Returns a findings-report dict conforming to the DO output contract.
    """
    root = Path(root)
    enabled = task_context.get("enabled-layers") or list(LAYERS)
    areas = task_context.get("application-area")

    corpus = _load_corpus(root, enabled, areas)
    if not corpus:
        return _report("no-knowledge", [], [])

    applicable: list[tuple[KnowledgeFile, list[str]]] = []
    for kf in corpus:
        ok, unknown = _matches(kf, task_context)
        if ok:
            applicable.append((kf, unknown))
    if not applicable:
        return _report("not-applicable", [], [])

    kept, suppressed = _resolve_precedence([kf for kf, _ in applicable])
    kept_set = {kf.path for kf in kept}
    unknown_by_path = {kf.path: u for kf, u in applicable if kf.path in kept_set}

    worklist = _narrow(kept, task_context)

    findings: list[dict[str, Any]] = []
    for kf in worklist:
        unknown = unknown_by_path.get(kf.path, [])
        findings.append({
            "id": kf.path,
            "severity": "info",
            "message": _message(kf, unknown),
            "references": [{"path": kf.path}],
            "confidence": "medium" if unknown else "high",
        })

    return _report("completed", findings, suppressed)


def _report(
    outcome: str, findings: list[dict[str, Any]], suppressed: list[dict[str, Any]]
) -> dict[str, Any]:
    return {
        "skill": {"id": SKILL_ID, "version": SKILL_VERSION},
        "outcome": outcome,
        "summary": {
            "counts": {
                "blocker": 0,
                "major": 0,
                "minor": 0,
                "info": len(findings),
            },
            "coverage": {
                "worklist-size": len(findings),
                "items-evaluated": len(findings),
            },
        },
        "findings": findings,
        "suppressed": suppressed,
    }
