#!/usr/bin/env python3
"""
BCQuality content validator.

Validates frontmatter, sections, and structural rules for knowledge files,
action skills, meta-skills, and the entry-point skill. Rules derived from
/skills/read.md, /skills/write.md, /skills/do.md, and /skills/entry.md.

Usage:
    python .github/scripts/validate_frontmatter.py [--root PATH]

Exit status: 0 on success (no errors), 1 on any error. Warnings do not fail.
"""
from __future__ import annotations

import argparse
import os
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


# --- Schema constants -------------------------------------------------------

KNOWLEDGE_REQUIRED_KEYS = {
    "bc-version", "domain", "keywords", "technologies",
    "countries", "application-area",
}
ACTION_SKILL_REQUIRED_KEYS = {
    "kind", "id", "version", "title", "description", "inputs", "outputs",
}
ACTION_SKILL_OPTIONAL_KEYS = {
    "bc-version", "technologies", "countries", "application-area", "sub-skills",
}
META_SKILL_REQUIRED_KEYS = {"kind", "id", "version", "title"}
ENTRY_SKILL_REQUIRED_KEYS = {"kind", "id", "version", "title"}

STANDARD_INPUTS = {
    "pr-diff", "object-list", "file-path", "repository", "telemetry-query",
}
ALLOWED_OUTPUTS = {"findings-report"}
VALID_SAMPLE_KINDS = {"good", "bad"}

ACTION_SKILL_SECTIONS = ["Source", "Relevance", "Worklist", "Action", "Output"]

LAYERS = ("microsoft", "community", "custom")
META_SKILL_FILES = {"read.md", "write.md", "do.md"}
ENTRY_SKILL_FILE = "entry.md"

MAX_KNOWLEDGE_LINES = 100

KEBAB_CASE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
ISO_ALPHA2 = re.compile(r"^[a-z]{2}$")
RANGE_SHORTHAND = re.compile(r"^(\d+)\.\.(\d+)$")
FENCED_CODE_BLOCK = re.compile(r"^```", re.MULTILINE)
HEADING_H2 = re.compile(r"^##\s+(.+?)\s*$", re.MULTILINE)


# --- Diagnostics ------------------------------------------------------------

@dataclass
class Diagnostic:
    level: str            # "error" | "warning"
    path: Path
    rule: str             # e.g. "R03"
    message: str
    line: int | None = None

    def format_plain(self, root: Path) -> str:
        rel = self.path.relative_to(root).as_posix()
        prefix = rel if self.line is None else f"{rel}:{self.line}"
        return f"{prefix}: [{self.rule}] {self.level}: {self.message}"

    def format_gha(self, root: Path) -> str:
        rel = self.path.relative_to(root).as_posix()
        loc = f"file={rel}"
        if self.line is not None:
            loc += f",line={self.line}"
        return f"::{self.level} {loc}::[{self.rule}] {self.message}"


@dataclass
class Report:
    diagnostics: list[Diagnostic] = field(default_factory=list)

    def error(self, path: Path, rule: str, message: str, line: int | None = None) -> None:
        self.diagnostics.append(Diagnostic("error", path, rule, message, line))

    def warn(self, path: Path, rule: str, message: str, line: int | None = None) -> None:
        self.diagnostics.append(Diagnostic("warning", path, rule, message, line))

    @property
    def errors(self) -> list[Diagnostic]:
        return [d for d in self.diagnostics if d.level == "error"]

    @property
    def warnings(self) -> list[Diagnostic]:
        return [d for d in self.diagnostics if d.level == "warning"]


# --- Frontmatter parsing ----------------------------------------------------

@dataclass
class Parsed:
    frontmatter: dict[str, Any] | None
    body: str
    body_start_line: int              # 1-based line number where body begins
    raw_lines: list[str]
    frontmatter_error: str | None     # yaml or delimiter issue


def parse_markdown(text: str) -> Parsed:
    lines = text.splitlines()
    if not lines or lines[0].rstrip() != "---":
        return Parsed(None, text, 1, lines, "missing opening '---' frontmatter delimiter")
    end_idx = None
    for i in range(1, len(lines)):
        if lines[i].rstrip() == "---":
            end_idx = i
            break
    if end_idx is None:
        return Parsed(None, text, 1, lines, "missing closing '---' frontmatter delimiter")
    yaml_text = "\n".join(lines[1:end_idx])
    try:
        fm = yaml.safe_load(yaml_text) or {}
    except yaml.YAMLError as e:
        return Parsed(None, text, end_idx + 2, lines, f"YAML parse error: {e}")
    if not isinstance(fm, dict):
        return Parsed(None, text, end_idx + 2, lines, "frontmatter must be a YAML mapping")
    body = "\n".join(lines[end_idx + 1:])
    return Parsed(fm, body, end_idx + 2, lines, None)


# --- Small helpers ----------------------------------------------------------

def is_non_empty_list_of_str(value: Any) -> bool:
    return isinstance(value, list) and len(value) > 0 and all(isinstance(v, str) and v for v in value)


def expand_bc_version(value: Any) -> tuple[list[int] | None, str | None]:
    """Return (expanded-list, error-message). One of the two is None."""
    if not isinstance(value, list) or not value:
        return None, "must be a non-empty list"
    # Case 1: all integers
    if all(isinstance(v, int) and not isinstance(v, bool) for v in value):
        if any(v <= 0 for v in value):
            return None, "integers must be positive"
        return sorted(set(value)), None
    # Case 2: single-element range-shorthand like "[26..28]"
    if len(value) == 1 and isinstance(value[0], str):
        m = RANGE_SHORTHAND.match(value[0].strip())
        if m:
            start, end = int(m.group(1)), int(m.group(2))
            if start > end:
                return None, f"range '{value[0]}' is not ascending"
            return list(range(start, end + 1)), None
    return None, "must be a list of integers or a single-element range shorthand like [26..28]"


def headings_in_order(body: str) -> list[tuple[str, int]]:
    """Return list of (heading-text, 1-based line-number-within-body) pairs."""
    out = []
    for i, line in enumerate(body.splitlines(), start=1):
        m = re.match(r"^##\s+(.+?)\s*$", line)
        if m:
            out.append((m.group(1).strip(), i))
    return out


# --- Validators -------------------------------------------------------------

def validate_knowledge(path: Path, parsed: Parsed, report: Report) -> None:
    # R01 frontmatter parseable
    if parsed.frontmatter_error:
        report.error(path, "R01", parsed.frontmatter_error, 1)
        return
    fm = parsed.frontmatter
    assert fm is not None

    # R02 required keys, no extras, none empty
    missing = KNOWLEDGE_REQUIRED_KEYS - fm.keys()
    extras = fm.keys() - KNOWLEDGE_REQUIRED_KEYS
    if missing:
        report.error(path, "R02", f"missing required frontmatter keys: {sorted(missing)}", 1)
    if extras:
        report.error(path, "R02", f"unexpected frontmatter keys: {sorted(extras)}", 1)
    for k in KNOWLEDGE_REQUIRED_KEYS & fm.keys():
        v = fm[k]
        if v is None or v == "" or v == []:
            report.error(path, "R02", f"frontmatter key '{k}' must not be empty", 1)

    # R03 bc-version
    if "bc-version" in fm:
        _, err = expand_bc_version(fm["bc-version"])
        if err:
            report.error(path, "R03", f"bc-version: {err}", 1)

    # R04 domain
    if "domain" in fm:
        if not isinstance(fm["domain"], str) or not fm["domain"].strip():
            report.error(path, "R04", "domain must be a non-empty string", 1)

    # R05 keywords
    if "keywords" in fm:
        kw = fm["keywords"]
        if not is_non_empty_list_of_str(kw):
            report.error(path, "R05", "keywords must be a non-empty list of strings", 1)
        else:
            bad = [k for k in kw if not KEBAB_CASE.match(k)]
            if bad:
                report.error(path, "R05", f"keywords must be lowercase kebab-case: {bad}", 1)
            if len(kw) > 10:
                report.warn(path, "R05", f"keywords count is {len(kw)}; consider trimming toward ≤10", 1)

    # R06 technologies
    if "technologies" in fm:
        t = fm["technologies"]
        if not is_non_empty_list_of_str(t):
            report.error(path, "R06", "technologies must be a non-empty list of strings", 1)
        elif "all" in t:
            report.error(path, "R06", "technologies must not use the 'all' sentinel; list each technology explicitly", 1)

    # R07 countries
    if "countries" in fm:
        c = fm["countries"]
        if not is_non_empty_list_of_str(c):
            report.error(path, "R07", "countries must be a non-empty list of strings", 1)
        elif "w1" in c and len(c) > 1:
            report.error(path, "R07", "'w1' is mutually exclusive with country codes", 1)
        elif "w1" not in c:
            bad = [x for x in c if not ISO_ALPHA2.match(x)]
            if bad:
                report.error(path, "R07", f"countries must be lowercase ISO alpha-2 codes or [w1]: {bad}", 1)

    # R08 application-area
    if "application-area" in fm:
        a = fm["application-area"]
        if not is_non_empty_list_of_str(a):
            report.error(path, "R08", "application-area must be a non-empty list of strings", 1)
        elif "all" in a and len(a) > 1:
            report.error(path, "R08", "'all' is mutually exclusive with specific application areas", 1)

    # R09 has ## Description
    headings = [h for h, _ in headings_in_order(parsed.body)]
    if "Description" not in headings:
        report.error(path, "R09", "missing required '## Description' section")

    # R10 no fenced code blocks
    for match in FENCED_CODE_BLOCK.finditer(parsed.body):
        # offset to a 1-based line number in the original file
        prefix = parsed.body[: match.start()]
        body_line = prefix.count("\n") + 1
        file_line = parsed.body_start_line + body_line - 1
        report.error(path, "R10", "knowledge files must not contain fenced code blocks", file_line)
        break  # one is enough; don't spam

    # R11 file size ≤ 100 lines
    total_lines = len(parsed.raw_lines)
    if total_lines > MAX_KNOWLEDGE_LINES:
        report.error(path, "R11", f"file is {total_lines} lines; max is {MAX_KNOWLEDGE_LINES}")


def validate_action_skill(path: Path, parsed: Parsed, report: Report) -> None:
    if parsed.frontmatter_error:
        report.error(path, "R01", parsed.frontmatter_error, 1)
        return
    fm = parsed.frontmatter
    assert fm is not None

    # R15 required keys; warn on unknown
    missing = ACTION_SKILL_REQUIRED_KEYS - fm.keys()
    if missing:
        report.error(path, "R15", f"missing required action-skill keys: {sorted(missing)}", 1)
    unknown = fm.keys() - ACTION_SKILL_REQUIRED_KEYS - ACTION_SKILL_OPTIONAL_KEYS
    if unknown:
        report.warn(path, "R15", f"unknown action-skill keys: {sorted(unknown)}", 1)
    for k in ACTION_SKILL_REQUIRED_KEYS & fm.keys():
        v = fm[k]
        if v is None or v == "" or v == []:
            report.error(path, "R15", f"action-skill key '{k}' must not be empty", 1)

    # R25 kind matches path
    if fm.get("kind") != "action-skill":
        report.error(path, "R25", f"file is in a layer skills folder but kind is '{fm.get('kind')}', expected 'action-skill'", 1)

    # R16 id kebab-case, version positive int
    if "id" in fm:
        if not isinstance(fm["id"], str) or not KEBAB_CASE.match(fm["id"]):
            report.error(path, "R16", f"id must be lowercase kebab-case: '{fm['id']}'", 1)
    if "version" in fm:
        v = fm["version"]
        if not isinstance(v, int) or isinstance(v, bool) or v <= 0:
            report.error(path, "R16", f"version must be a positive integer: {v!r}", 1)

    # R17 inputs
    if "inputs" in fm:
        inp = fm["inputs"]
        if not is_non_empty_list_of_str(inp):
            report.error(path, "R17", "inputs must be a non-empty list of strings", 1)
        else:
            unknown_inputs = [x for x in inp if x not in STANDARD_INPUTS]
            if unknown_inputs:
                report.warn(path, "R17", f"inputs contains non-standard values {unknown_inputs}; standard set is {sorted(STANDARD_INPUTS)}", 1)

    # R18 outputs
    if "outputs" in fm:
        out = fm["outputs"]
        if not is_non_empty_list_of_str(out):
            report.error(path, "R18", "outputs must be a non-empty list of strings", 1)
        else:
            bad = [x for x in out if x not in ALLOWED_OUTPUTS]
            if bad:
                report.error(path, "R18", f"outputs contains non-allowed values {bad}; currently only {sorted(ALLOWED_OUTPUTS)} is defined", 1)

    # R19 optional filter dimensions, if present
    if "bc-version" in fm:
        _, err = expand_bc_version(fm["bc-version"])
        if err:
            report.error(path, "R19", f"bc-version: {err}", 1)
    if "technologies" in fm:
        t = fm["technologies"]
        if not is_non_empty_list_of_str(t):
            report.error(path, "R19", "technologies must be a non-empty list of strings", 1)
        elif "all" in t:
            report.error(path, "R19", "technologies must not use the 'all' sentinel", 1)
    if "countries" in fm:
        c = fm["countries"]
        if not is_non_empty_list_of_str(c):
            report.error(path, "R19", "countries must be a non-empty list of strings", 1)
        elif "w1" in c and len(c) > 1:
            report.error(path, "R19", "'w1' is mutually exclusive with country codes", 1)
        elif "w1" not in c:
            bad = [x for x in c if not ISO_ALPHA2.match(x)]
            if bad:
                report.error(path, "R19", f"countries must be ISO alpha-2 or [w1]: {bad}", 1)
    if "application-area" in fm:
        a = fm["application-area"]
        if not is_non_empty_list_of_str(a):
            report.error(path, "R19", "application-area must be a non-empty list of strings", 1)
        elif "all" in a and len(a) > 1:
            report.error(path, "R19", "'all' is mutually exclusive with specific application areas", 1)

    # R20 sub-skills shape
    if "sub-skills" in fm:
        ss = fm["sub-skills"]
        if not is_non_empty_list_of_str(ss):
            report.error(path, "R20", "sub-skills must be a non-empty list of repo-relative paths", 1)
        else:
            bad = [x for x in ss if not x.endswith(".md")]
            if bad:
                report.error(path, "R20", f"sub-skills entries must end in '.md': {bad}", 1)

    # R21 five required sections, in order, each exactly once
    heads = [h for h, _ in headings_in_order(parsed.body)]
    indices: list[int] = []
    for required in ACTION_SKILL_SECTIONS:
        occurrences = [i for i, h in enumerate(heads) if h == required]
        if not occurrences:
            report.error(path, "R21", f"missing required section '## {required}'")
        elif len(occurrences) > 1:
            report.error(path, "R21", f"section '## {required}' appears {len(occurrences)} times; must appear once")
            indices.append(occurrences[0])
        else:
            indices.append(occurrences[0])
    if len(indices) == len(ACTION_SKILL_SECTIONS) and indices != sorted(indices):
        order = [heads[i] for i in indices]
        report.error(path, "R21", f"required sections out of order: {order}; expected {ACTION_SKILL_SECTIONS}")


def validate_meta_skill(path: Path, parsed: Parsed, report: Report) -> None:
    if parsed.frontmatter_error:
        report.error(path, "R01", parsed.frontmatter_error, 1)
        return
    fm = parsed.frontmatter
    assert fm is not None
    missing = META_SKILL_REQUIRED_KEYS - fm.keys()
    if missing:
        report.error(path, "R22", f"missing required meta-skill keys: {sorted(missing)}", 1)
    for k in META_SKILL_REQUIRED_KEYS & fm.keys():
        v = fm[k]
        if v is None or v == "" or v == []:
            report.error(path, "R22", f"meta-skill key '{k}' must not be empty", 1)
    if fm.get("kind") != "meta-skill":
        report.error(path, "R25", f"file in /skills/ is a meta-skill by path but kind is '{fm.get('kind')}', expected 'meta-skill'", 1)
    if "id" in fm and (not isinstance(fm["id"], str) or not KEBAB_CASE.match(fm["id"])):
        report.error(path, "R22", f"id must be lowercase kebab-case: '{fm['id']}'", 1)
    if "version" in fm:
        v = fm["version"]
        if not isinstance(v, int) or isinstance(v, bool) or v <= 0:
            report.error(path, "R22", f"version must be a positive integer: {v!r}", 1)


def validate_entry_skill(path: Path, parsed: Parsed, report: Report) -> None:
    if parsed.frontmatter_error:
        report.error(path, "R01", parsed.frontmatter_error, 1)
        return
    fm = parsed.frontmatter
    assert fm is not None
    missing = ENTRY_SKILL_REQUIRED_KEYS - fm.keys()
    if missing:
        report.error(path, "R23", f"missing required entry-point keys: {sorted(missing)}", 1)
    for k in ENTRY_SKILL_REQUIRED_KEYS & fm.keys():
        v = fm[k]
        if v is None or v == "" or v == []:
            report.error(path, "R23", f"entry-point key '{k}' must not be empty", 1)
    if fm.get("kind") != "entry-point":
        report.error(path, "R25", f"file is /skills/entry.md but kind is '{fm.get('kind')}', expected 'entry-point'", 1)
    if fm.get("id") != "entry":
        report.error(path, "R23", f"entry-point id must be 'entry', got '{fm.get('id')}'", 1)
    if "version" in fm:
        v = fm["version"]
        if not isinstance(v, int) or isinstance(v, bool) or v <= 0:
            report.error(path, "R23", f"version must be a positive integer: {v!r}", 1)


# --- Path and sample checks -------------------------------------------------

def classify(path_from_root: Path) -> str | None:
    """Return 'knowledge' | 'action-skill' | 'meta' | 'entry' | None."""
    parts = path_from_root.parts
    if len(parts) < 2:
        return None
    top = parts[0]
    if top == "skills":
        if len(parts) == 2:
            name = parts[1]
            if name == ENTRY_SKILL_FILE:
                return "entry"
            if name in META_SKILL_FILES:
                return "meta"
        return None
    if top in LAYERS and path_from_root.suffix == ".md":
        if len(parts) >= 3 and parts[1] == "skills":
            return "action-skill"
        if len(parts) >= 4 and parts[1] == "knowledge":
            return "knowledge"
    return None


def validate_knowledge_path(path: Path, root: Path, report: Report) -> None:
    rel = path.relative_to(root)
    parts = rel.parts
    # R13 expected shape: <layer>/knowledge/<domain>/<slug>.md
    if len(parts) != 4:
        report.error(path, "R13", f"knowledge file must live at <layer>/knowledge/<domain>/<slug>.md; got {rel.as_posix()}")
        return
    slug = path.stem
    # R12 filename kebab-case
    if not KEBAB_CASE.match(slug):
        report.error(path, "R12", f"filename slug must be lowercase kebab-case: '{slug}'")


def validate_samples_in_domain(domain_dir: Path, root: Path, report: Report) -> None:
    """R14: every non-.md file must match <slug>.<kind>.<ext> with <slug>.md present."""
    if not domain_dir.is_dir():
        return
    article_slugs = {p.stem for p in domain_dir.glob("*.md")}
    for entry in domain_dir.iterdir():
        if not entry.is_file() or entry.suffix == ".md":
            continue
        name = entry.name
        # Expect <slug>.<kind>.<ext>
        m = re.match(r"^(?P<slug>[a-z0-9]+(?:-[a-z0-9]+)*)\.(?P<kind>[a-z0-9]+)\.(?P<ext>[a-z0-9]+)$", name)
        if not m:
            report.error(entry, "R14", f"sample file name must match '<slug>.<kind>.<ext>' with kebab-case slug: '{name}'")
            continue
        slug = m.group("slug")
        kind = m.group("kind")
        if slug not in article_slugs:
            report.error(entry, "R14", f"orphan sample: no matching article '{slug}.md' in {domain_dir.relative_to(root).as_posix()}")
        if kind not in VALID_SAMPLE_KINDS:
            report.warn(entry, "R14", f"non-standard sample kind '{kind}'; standard kinds are {sorted(VALID_SAMPLE_KINDS)}")


# --- Orchestration ----------------------------------------------------------

@dataclass
class SkillRecord:
    path: Path
    kind: str            # frontmatter kind
    skill_id: str | None


def run(root: Path) -> Report:
    report = Report()
    skill_records: list[SkillRecord] = []

    # Walk declared top-level folders only; avoid wandering into .git, etc.
    walk_roots = [root / "skills"] + [root / layer for layer in LAYERS]
    candidate_files: list[Path] = []
    for wr in walk_roots:
        if wr.exists():
            candidate_files.extend(p for p in wr.rglob("*") if p.is_file())

    # First pass: classify and validate each file
    for path in candidate_files:
        rel = path.relative_to(root)
        kind = classify(rel)
        if kind is None:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError as e:
            report.error(path, "R01", f"file is not valid UTF-8: {e}")
            continue
        parsed = parse_markdown(text)

        if kind == "knowledge":
            validate_knowledge_path(path, root, report)
            validate_knowledge(path, parsed, report)
        elif kind == "action-skill":
            validate_action_skill(path, parsed, report)
            if parsed.frontmatter and isinstance(parsed.frontmatter.get("id"), str):
                skill_records.append(SkillRecord(path, "action-skill", parsed.frontmatter["id"]))
        elif kind == "meta":
            validate_meta_skill(path, parsed, report)
            if parsed.frontmatter and isinstance(parsed.frontmatter.get("id"), str):
                skill_records.append(SkillRecord(path, "meta-skill", parsed.frontmatter["id"]))
        elif kind == "entry":
            validate_entry_skill(path, parsed, report)
            if parsed.frontmatter and isinstance(parsed.frontmatter.get("id"), str):
                skill_records.append(SkillRecord(path, "entry-point", parsed.frontmatter["id"]))

    # Second pass: sample files per knowledge domain
    for layer in LAYERS:
        kn_root = root / layer / "knowledge"
        if not kn_root.is_dir():
            continue
        for domain_dir in kn_root.iterdir():
            if domain_dir.is_dir():
                validate_samples_in_domain(domain_dir, root, report)

    # Third pass: R24 unique ids within kind
    by_kind: dict[str, dict[str, list[Path]]] = {}
    for rec in skill_records:
        if rec.skill_id is None:
            continue
        by_kind.setdefault(rec.kind, {}).setdefault(rec.skill_id, []).append(rec.path)
    for kind, by_id in by_kind.items():
        for sid, paths in by_id.items():
            if len(paths) > 1:
                for p in paths:
                    others = [q.relative_to(root).as_posix() for q in paths if q != p]
                    report.error(p, "R24", f"skill id '{sid}' ({kind}) is not unique; also defined in: {others}")

    return report


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description="BCQuality frontmatter and structure validator.")
    parser.add_argument("--root", default=".", help="Repository root (default: current directory).")
    args = parser.parse_args(argv)

    root = Path(args.root).resolve()
    report = run(root)

    gha = os.environ.get("GITHUB_ACTIONS") == "true"
    for d in report.diagnostics:
        line = d.format_gha(root) if gha else d.format_plain(root)
        print(line)

    n_err = len(report.errors)
    n_warn = len(report.warnings)
    print(f"\nValidator: {n_err} error(s), {n_warn} warning(s)")
    return 1 if n_err else 0


if __name__ == "__main__":
    sys.exit(main())
