#!/usr/bin/env python3
from __future__ import annotations

import copy
import json
import tempfile
import unittest
from pathlib import Path

import yaml

from generation_contracts import (
    MAX_ARTIFACT_BYTES,
    _fallback_schema_errors,
    load_bounded_json,
    load_schema,
    schema_errors,
    validate_report_semantics,
    validate_requirement_semantics,
)


ROOT = Path(__file__).resolve().parents[2]
REQUIREMENT_SCHEMA = load_schema(ROOT / "schemas/requirement-spec-v1.schema.json")
REPORT_SCHEMA = load_schema(ROOT / "schemas/generated-files-report-v1.schema.json")
VALID_REQUIREMENT = load_bounded_json(ROOT / "schemas/examples/requirement-spec-v1.example.json")
VALID_REPORT = load_bounded_json(ROOT / "schemas/examples/generated-files-report-v1.example.json")
REVIEW_INPUTS = {"pr-diff", "object-list", "file-path", "repository", "telemetry-query"}


def frontmatter(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    return yaml.safe_load(text.split("---", 2)[1])


def route(task: dict) -> dict:
    inputs = set(task.get("inputs-available", []))
    action = task.get("action")
    has_generation = "requirement-spec" in inputs
    has_review = bool(inputs & REVIEW_INPUTS)
    accepted = {(item["kind"], item["version"]) for item in task.get("accepted-outputs", [])}

    if has_generation and has_review and action is None:
        return {"outcome": "failed", "outcome-reason": "ambiguous-action", "dispatch": []}
    if action == "generate":
        if not has_generation or ("generated-files-report", 1) not in accepted:
            return {"outcome": "no-match", "dispatch": []}
        return {
            "outcome": "routed",
            "dispatch": [{
                "skill": {
                    "id": "al-code-generation",
                    "version": 1,
                    "path": "microsoft/skills/generate/al-code-generation.md",
                },
                "inputs": ["requirement-spec"],
                "output": {"kind": "generated-files-report", "version": 1},
            }],
        }
    if action == "review" or (action is None and has_review and not has_generation):
        if accepted and ("findings-report", 1) not in accepted:
            return {"outcome": "no-match", "dispatch": []}
        return {
            "outcome": "routed",
            "dispatch": [{
                "skill": {
                    "id": "al-code-review",
                    "version": 1,
                    "path": "microsoft/skills/review/al-code-review.md",
                },
                "inputs": sorted(inputs & {"pr-diff", "file-path"}),
                "output": {"kind": "findings-report", "version": 1},
            }],
        }
    return {"outcome": "failed", "outcome-reason": "explicit-generate-action-required", "dispatch": []}


class GenerationContractTests(unittest.TestCase):
    def assert_requirement_invalid(self, document: dict) -> None:
        self.assertTrue(
            schema_errors(REQUIREMENT_SCHEMA, document) or validate_requirement_semantics(document),
            "expected invalid requirement",
        )

    def assert_report_invalid(self, document: dict) -> None:
        self.assertTrue(
            schema_errors(REPORT_SCHEMA, document)
            or validate_report_semantics(document, requirement=VALID_REQUIREMENT),
            "expected invalid report",
        )

    def test_published_examples_are_strict_and_semantically_valid(self) -> None:
        self.assertEqual([], schema_errors(REQUIREMENT_SCHEMA, VALID_REQUIREMENT))
        self.assertEqual([], validate_requirement_semantics(VALID_REQUIREMENT))
        self.assertEqual([], schema_errors(REPORT_SCHEMA, VALID_REPORT))
        self.assertEqual([], validate_report_semantics(VALID_REPORT, requirement=VALID_REQUIREMENT))
        self.assertEqual([], _fallback_schema_errors(REQUIREMENT_SCHEMA, VALID_REQUIREMENT))
        self.assertEqual([], _fallback_schema_errors(REPORT_SCHEMA, VALID_REPORT))

    def test_malformed_and_duplicate_key_json_fail(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            malformed = Path(directory) / "malformed.json"
            malformed.write_text('{"schema-version":', encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "malformed JSON"):
                load_bounded_json(malformed)
            duplicate = Path(directory) / "duplicate.json"
            duplicate.write_text('{"schema-version":1,"schema-version":1}', encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "duplicate JSON key"):
                load_bounded_json(duplicate)
            oversized = Path(directory) / "oversized.json"
            oversized.write_bytes(b" " * 1_048_577)
            with self.assertRaisesRegex(ValueError, "exceeds 1048576 bytes"):
                load_bounded_json(oversized)
            invalid_utf8 = Path(directory) / "invalid-utf8.json"
            invalid_utf8.write_bytes(b"\xff")
            with self.assertRaisesRegex(ValueError, "not UTF-8"):
                load_bounded_json(invalid_utf8)

    def test_requirement_unknown_version_and_unbounded_artifacts_fail(self) -> None:
        unknown = copy.deepcopy(VALID_REQUIREMENT)
        unknown["schema-version"] = 2
        self.assert_requirement_invalid(unknown)
        unbounded = copy.deepcopy(VALID_REQUIREMENT)
        unbounded["requested-artifacts"] *= 65
        self.assert_requirement_invalid(unbounded)

    def test_unsafe_paths_fail(self) -> None:
        for path in (
            "/tmp/Object.al",
            "C:/Object.al",
            "../Object.al",
            "src/../Object.al",
            "src/SampleApp/./Object.al",
            ".git/Object.al",
            "src\\Object.al",
            "outside/Object.al",
        ):
            with self.subTest(path=path):
                document = copy.deepcopy(VALID_REQUIREMENT)
                document["requested-artifacts"][0]["path"] = path
                self.assert_requirement_invalid(document)

    def test_duplicate_overwrite_delete_and_rename_requests_fail(self) -> None:
        duplicate = copy.deepcopy(VALID_REQUIREMENT)
        duplicate["requested-artifacts"].append(copy.deepcopy(duplicate["requested-artifacts"][0]))
        self.assert_requirement_invalid(duplicate)
        for operation in ("overwrite", "delete", "rename"):
            with self.subTest(operation=operation):
                document = copy.deepcopy(VALID_REQUIREMENT)
                document["requested-artifacts"][0]["operation"] = operation
                self.assert_requirement_invalid(document)
        existing = {"src/SampleApp/Setup/CQSampleSetup.Table.al"}
        self.assertTrue(validate_requirement_semantics(VALID_REQUIREMENT, existing_paths=existing))
        aliased = copy.deepcopy(VALID_REQUIREMENT)
        aliased["requested-artifacts"][0]["path"] = "src/SampleApp/./Setup/CQSampleSetup.Table.al"
        self.assert_requirement_invalid(aliased)
        self.assertTrue(validate_requirement_semantics(aliased, existing_paths=existing))

    def test_id_range_failures(self) -> None:
        outside = copy.deepcopy(VALID_REQUIREMENT)
        outside["requested-artifacts"][0]["object-id"] = 80000
        self.assert_requirement_invalid(outside)
        inverted = copy.deepcopy(VALID_REQUIREMENT)
        inverted["target"]["app"]["id-ranges"][0] = {"from": 70049, "to": 70000}
        self.assert_requirement_invalid(inverted)
        overlapping = copy.deepcopy(VALID_REQUIREMENT)
        overlapping["target"]["app"]["id-ranges"].append({"from": 70025, "to": 70075})
        self.assert_requirement_invalid(overlapping)

    def test_report_duplicate_overwrite_findings_id_range_and_size_fail(self) -> None:
        duplicate = copy.deepcopy(VALID_REPORT)
        duplicate["artifacts"].append(copy.deepcopy(duplicate["artifacts"][0]))
        duplicate["summary"]["artifact-count"] = 2
        duplicate["summary"]["total-content-bytes"] *= 2
        self.assert_report_invalid(duplicate)
        overwrite = copy.deepcopy(VALID_REPORT)
        overwrite["artifacts"][0]["operation"] = "overwrite"
        self.assert_report_invalid(overwrite)
        findings = copy.deepcopy(VALID_REPORT)
        findings["findings"] = []
        self.assert_report_invalid(findings)
        outside_id = copy.deepcopy(VALID_REPORT)
        outside_id["artifacts"][0]["object-id"] = 80000
        self.assert_report_invalid(outside_id)
        changed_id = copy.deepcopy(VALID_REPORT)
        changed_id["artifacts"][0]["object-id"] = 70001
        self.assert_report_invalid(changed_id)
        changed_name = copy.deepcopy(VALID_REPORT)
        changed_name["artifacts"][0]["object-name"] = "CQ Renamed Setup"
        self.assert_report_invalid(changed_name)
        oversized = copy.deepcopy(VALID_REPORT)
        oversized["artifacts"][0]["content"] = "é" * (MAX_ARTIFACT_BYTES // 2 + 1)
        oversized["summary"]["total-content-bytes"] = len(oversized["artifacts"][0]["content"].encode("utf-8"))
        self.assert_report_invalid(oversized)

    def test_any_guidance_omission_forces_partial(self) -> None:
        report = copy.deepcopy(VALID_REPORT)
        report["omitted-guidance"] = [{
            "reference": {
                "path": "microsoft/knowledge/appsource/object-affixes-prevent-collisions.md",
                "sha": report["knowledge-revision"]["commit-sha"],
            },
            "reason": "context-budget",
            "detail": "Ranked after the configured context budget.",
        }]
        report["summary"]["coverage"]["omitted-count"] = 1
        self.assert_report_invalid(report)
        report["outcome"] = "partial"
        report["summary"]["coverage"]["relevant-count"] = 2
        self.assertEqual([], schema_errors(REPORT_SCHEMA, report))
        self.assertEqual([], validate_report_semantics(report, requirement=VALID_REQUIREMENT))

    def test_coverage_cannot_hide_unopened_relevant_guidance(self) -> None:
        report = copy.deepcopy(VALID_REPORT)
        report["summary"]["coverage"]["relevant-count"] = 2
        report["summary"]["coverage"]["worklist-count"] = 2
        self.assert_report_invalid(report)

    def test_immutable_revision_can_identify_a_fork(self) -> None:
        report = copy.deepcopy(VALID_REPORT)
        report["knowledge-revision"]["repository"] = "https://github.com/contoso/BCQuality"
        self.assertEqual([], schema_errors(REPORT_SCHEMA, report))
        self.assertEqual([], validate_report_semantics(report, requirement=VALID_REQUIREMENT))

    def test_deterministic_entry_routing_matrix(self) -> None:
        cases = {
            "generation-only": (
                {
                    "action": "generate",
                    "inputs-available": ["requirement-spec"],
                    "accepted-outputs": [{"kind": "generated-files-report", "version": 1}],
                },
                "al-code-generation",
            ),
            "legacy-review-only": (
                {"inputs-available": ["pr-diff"]},
                "al-code-review",
            ),
            "both-explicit-generate": (
                {
                    "action": "generate",
                    "inputs-available": ["pr-diff", "requirement-spec"],
                    "accepted-outputs": [{"kind": "generated-files-report", "version": 1}],
                },
                "al-code-generation",
            ),
            "both-explicit-review": (
                {
                    "action": "review",
                    "inputs-available": ["pr-diff", "requirement-spec"],
                    "accepted-outputs": [{"kind": "findings-report", "version": 1}],
                },
                "al-code-review",
            ),
        }
        for name, (task, expected) in cases.items():
            with self.subTest(name=name):
                result = route(task)
                self.assertEqual("routed", result["outcome"])
                self.assertEqual(expected, result["dispatch"][0]["skill"]["id"])
                self.assertIn("output", result["dispatch"][0])

        ambiguous = route({"inputs-available": ["pr-diff", "requirement-spec"]})
        self.assertEqual("failed", ambiguous["outcome"])
        self.assertEqual("ambiguous-action", ambiguous["outcome-reason"])
        wrong_version = route({
            "action": "generate",
            "inputs-available": ["requirement-spec"],
            "accepted-outputs": [{"kind": "generated-files-report", "version": 2}],
        })
        self.assertEqual("no-match", wrong_version["outcome"])

    def test_current_non_capability_consumers_remain_generation_ineligible(self) -> None:
        result = route({"inputs-available": ["repository"]})
        self.assertEqual("al-code-review", result["dispatch"][0]["skill"]["id"])
        no_action = route({
            "inputs-available": ["requirement-spec"],
            "accepted-outputs": [{"kind": "generated-files-report", "version": 1}],
        })
        self.assertEqual("failed", no_action["outcome"])

    def test_generation_skill_shape_and_internal_references(self) -> None:
        skill_path = ROOT / "microsoft/skills/generate/al-code-generation.md"
        metadata = frontmatter(skill_path)
        self.assertEqual("al-code-generation", metadata["id"])
        self.assertEqual(["requirement-spec"], metadata["inputs"])
        self.assertEqual(["generated-files-report"], metadata["outputs"])
        self.assertEqual(1, metadata["output-version"])
        for relative in (
            "schemas/requirement-spec-v1.schema.json",
            "schemas/generated-files-report-v1.schema.json",
            "schemas/examples/requirement-spec-v1.example.json",
            "schemas/examples/generated-files-report-v1.example.json",
            "microsoft/knowledge/appsource/object-affixes-prevent-collisions.md",
            "microsoft/knowledge/appsource/object-affixes-prevent-collisions.good.al",
        ):
            self.assertTrue((ROOT / relative).is_file(), relative)

    def test_plugin_bridges_are_intent_isolated(self) -> None:
        review = (ROOT / "skills/bcquality-al-review/SKILL.md").read_text(encoding="utf-8")
        generate = (ROOT / "skills/bcquality-al-generate/SKILL.md").read_text(encoding="utf-8")
        self.assertIn("Do **not** use this skill to *generate* AL code", review)
        self.assertNotIn("action: generate", review)
        self.assertIn("action: generate", generate)
        self.assertIn("generated-files-report", generate)
        self.assertNotIn("findings-report", generate)


if __name__ == "__main__":
    unittest.main(verbosity=2)
