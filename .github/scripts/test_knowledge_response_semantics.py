"""Regress input fidelity and complete citation reads using consumer evidence."""
import copy
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[2]
TOOL = REPO / "tools/validate_knowledge_response.py"
spec = importlib.util.spec_from_file_location("knowledge_validator", TOOL)
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class KnowledgeSemantics(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        (self.root / "schemas").mkdir()
        (self.root / "schemas/knowledge-response.schema.json").write_bytes((REPO / "schemas/knowledge-response.schema.json").read_bytes())
        self.path = "microsoft/knowledge/performance/example.md"
        self.article = self.root / self.path
        self.article.parent.mkdir(parents=True)
        self.article.write_bytes(b"# Example\n\nComplete article content.\n")
        self.question = "  Question with accents: caf\u00e9?\r\n "
        self.response = {"skill": {"id": "al-knowledge", "version": 1},
            "outcome": "completed", "question": self.question, "answer": "Supported answer.",
            "references": [{"path": self.path, "applicability": "applicable", "unknown": []}], "suppressed": []}
        content = self.article.read_bytes()
        self.evidence = {"runId": "test-run", "questionSha256": hashlib.sha256(self.question.encode()).hexdigest(),
            "reads": [{"path": self.path, "complete": True, "bytes": len(content), "sha256": hashlib.sha256(content).hexdigest()}]}

    def errors(self, evidence=True):
        return module.validate_response(self.response, question=self.question, root=self.root,
            evidence=self.evidence if evidence else None, run_id="test-run")

    def test_disabled_citation_layer(self):
        errors = module.validate_response(self.response, question=self.question, root=self.root,
            evidence=self.evidence, run_id="test-run", enabled_layers=["community"])
        self.assertTrue(any("disabled layer" in error for error in errors))

    def test_configuration_suppression_disabled_layer(self):
        self.response.update(outcome="no-knowledge", references=[], suppressed=[{"path": self.path, "reason": "configuration"}])
        self.assertEqual(module.validate_response(self.response, question=self.question, root=self.root,
            run_id="test-run", enabled_layers=[]), [])

    def test_precedence_suppression_disabled_layer(self):
        self.response.update(outcome="no-knowledge", references=[], suppressed=[{"path": self.path, "reason": "layer-precedence"}])
        self.assertTrue(module.validate_response(self.response, question=self.question, root=self.root,
            run_id="test-run", enabled_layers=[]))

    def test_suppressed_path_traversal(self):
        self.response["suppressed"] = [{"path": "microsoft/knowledge/../skills/x.md", "reason": "configuration"}]
        self.assertTrue(self.errors())

    def test_missing_suppressed_file(self):
        self.response["suppressed"] = [{"path": "custom/knowledge/missing.md", "reason": "configuration"}]
        self.assertTrue(self.errors())

    def test_enabled_layers_cli(self):
        response_file = self.root / "response.json"
        question_file = self.root / "question.txt"
        evidence_file = self.root / "reads.json"
        response_file.write_text(json.dumps(self.response), encoding="utf-8")
        question_file.write_bytes(self.question.encode("utf-8"))
        evidence_file.write_text(json.dumps(self.evidence), encoding="utf-8")
        result = subprocess.run([sys.executable, str(TOOL), str(response_file), "--root", str(self.root),
            "--question-file", str(question_file), "--read-evidence", str(evidence_file),
            "--run-id", "test-run", "--enabled-layers", "community"], capture_output=True, text=True)
        self.assertEqual(result.returncode, 1)
        self.assertIn("disabled layer", result.stdout)

    def test_unknown_enabled_layer(self):
        self.assertTrue(module.validate_response(self.response, question=self.question, root=self.root,
            evidence=self.evidence, run_id="test-run", enabled_layers=["unknown"]))

    def test_valid_and_unchanged(self):
        original = copy.deepcopy(self.response)
        self.assertEqual(self.errors(), [])
        self.assertEqual(self.response, original)

    def test_rewritten_question(self):
        self.response["question"] = "A paraphrase"
        self.assertTrue(self.errors())

    def test_question_whitespace(self):
        self.response["question"] = self.question.strip()
        self.assertTrue(self.errors())

    def test_missing_article(self):
        self.response["references"][0]["path"] = "microsoft/knowledge/performance/missing.md"
        self.assertTrue(self.errors())

    def test_missing_read_evidence(self):
        self.assertTrue(self.errors(evidence=False))

    def test_truncated_read(self):
        self.evidence["reads"][0]["complete"] = False
        self.assertTrue(self.errors())

    def test_byte_count(self):
        self.evidence["reads"][0]["bytes"] -= 1
        self.assertTrue(self.errors())

    def test_changed_body(self):
        self.article.write_bytes(b"Changed body\n")
        self.assertTrue(self.errors())

    def test_wrong_hash(self):
        self.evidence["reads"][0]["sha256"] = "0" * 64
        self.assertTrue(self.errors())

    def test_same_basename_other_layer(self):
        self.evidence["reads"][0]["path"] = self.path.replace("microsoft/", "custom/")
        self.assertTrue(self.errors())

    def test_wrong_run(self):
        self.evidence["runId"] = "previous-run"
        self.assertTrue(self.errors())

    def test_wrong_question_evidence(self):
        self.evidence["questionSha256"] = "0" * 64
        self.assertTrue(self.errors())

    def test_path_traversal(self):
        self.response["references"][0]["path"] = "microsoft/knowledge/../skills/example.md"
        self.assertTrue(self.errors())

    def test_empty_reference_outcomes(self):
        for outcome in ("failed", "no-knowledge"):
            self.response.update(outcome=outcome, references=[], **{"outcome-reason": "No usable knowledge"})
            self.assertEqual(self.errors(evidence=False), [])

    def test_schema_violation(self):
        self.response["references"][0].update(applicability="conditional", unknown=[])
        self.assertTrue(self.errors())

    def test_duplicate_read_evidence(self):
        self.evidence["reads"].append(copy.deepcopy(self.evidence["reads"][0]))
        self.assertTrue(self.errors())

    def test_cli_preserves_question_and_rejects_changes(self):
        question = self.root / "question.txt"
        question.write_bytes(self.question.encode())
        response = self.root / "response.json"
        evidence = self.root / "evidence.json"
        response.write_text(json.dumps(self.response), encoding="utf-8")
        evidence.write_text(json.dumps(self.evidence), encoding="utf-8")
        command = [sys.executable, str(TOOL), str(response), "--root", str(self.root),
            "--question-file", str(question), "--read-evidence", str(evidence), "--run-id", "test-run"]
        result = subprocess.run(command, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertTrue(json.loads(result.stdout)["valid"])
        self.response["question"] = self.question.strip()
        response.write_text(json.dumps(self.response), encoding="utf-8")
        result = subprocess.run(command, capture_output=True, text=True)
        self.assertEqual(result.returncode, 1, result.stdout + result.stderr)

    def test_strict_json_duplicate_key(self):
        file = self.root / "duplicate.json"
        file.write_text('{"question":"one","question":"two"}')
        with self.assertRaises(ValueError):
            module.strict_json(file)


if __name__ == "__main__":
    unittest.main()
