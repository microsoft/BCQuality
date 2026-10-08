"""Validate a knowledge response against its question and trusted read evidence.

Read evidence must come from the consumer's successful tool results in this run,
not from the answering agent's claims. This checks identity and complete-read
evidence; it does not prove comprehension or that every claim follows a source.
Requires jsonschema. Does not repair or rewrite the response.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath

from jsonschema import Draft7Validator


def validate_response(response, *, question, root, evidence=None, run_id, enabled_layers=("microsoft", "community", "custom")):
    root = Path(root).resolve()
    schema = json.loads((root / "schemas/knowledge-response.schema.json").read_text(encoding="utf-8-sig"))
    validator = Draft7Validator(schema)
    errors = [f"Schema: {error.message}" for error in validator.iter_errors(response)]
    if errors:
        return errors
    if response["question"] != question:
        errors.append("question must equal the bound input exactly, including whitespace")
    known_layers = {"microsoft", "community", "custom"}
    enabled_layers = set(enabled_layers)
    if not enabled_layers <= known_layers:
        errors.append("Unknown enabled layers")
    for entry in response["references"] + response["suppressed"]:
        name = entry["path"]
        parts = name.split("/")
        file = (root / name).resolve()
        if "\\" in name or any(part in ("", ".", "..") for part in parts) or not file.is_relative_to(root):
            errors.append(f"Noncanonical corpus path: {name}")
        elif not file.is_file():
            errors.append(f"Corpus path does not exist: {name}")
        if parts[0] not in enabled_layers:
            # Configuration exclusions may identify disabled layers, never citations.
            if entry in response["references"] or entry.get("reason") != "configuration":
                errors.append(f"Path belongs to a disabled layer: {name}")
    reads = {}
    if evidence is not None:
        if not isinstance(evidence, dict):
            errors.append("Read evidence must be an object")
        else:
            if evidence.get("runId") != run_id:
                errors.append("Read evidence belongs to a different run")
            expected_hash = hashlib.sha256(question.encode("utf-8")).hexdigest()
            if evidence.get("questionSha256") != expected_hash:
                errors.append("Read evidence belongs to a different question")
            records = evidence.get("reads")
            if not isinstance(records, list):
                errors.append("Read evidence must contain a reads array")
            else:
                for record in records:
                    if not isinstance(record, dict) or not isinstance(record.get("path"), str):
                        errors.append("Invalid read evidence record")
                        continue
                    if record["path"] in reads:
                        errors.append(f"Duplicate read evidence: {record['path']}")
                    reads[record["path"]] = record
    for reference in response["references"]:
        name = reference["path"]
        parts = name.split("/")
        if "\\" in name or any(part in ("", ".", "..") for part in parts) or PurePosixPath(name).is_absolute():
            errors.append(f"Noncanonical citation path: {name}")
            continue
        file = (root / name).resolve()
        if not file.is_relative_to(root) or not file.is_file():
            errors.append(f"Citation is missing or outside the corpus: {name}")
            continue
        record = reads.get(name)
        if record is None or record.get("complete") is not True:
            errors.append(f"No complete read evidence for citation: {name}")
            continue
        content = file.read_bytes()
        try:
            content.decode("utf-8")
        except UnicodeDecodeError:
            errors.append(f"Citation is not strict UTF-8: {name}")
            continue
        if type(record.get("bytes")) is not int or record["bytes"] != len(content):
            errors.append(f"Read byte count does not match the full article: {name}")
        if record.get("sha256") != hashlib.sha256(content).hexdigest():
            errors.append(f"Read content hash does not match the live article: {name}")
    return errors


def strict_json(file):
    def pairs(items):
        result = {}
        for key, value in items:
            if key in result:
                raise ValueError(f"Duplicate JSON key: {key}")
            result[key] = value
        return result

    def invalid_constant(value):
        raise ValueError(f"Invalid JSON constant: {value}")

    return json.loads(Path(file).read_text(encoding="utf-8-sig"), object_pairs_hook=pairs, parse_constant=invalid_constant)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("response", type=Path)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    parser.add_argument("--question-file", type=Path, required=True, help="Exact bound input as UTF-8; no whitespace trimming")
    parser.add_argument("--read-evidence", type=Path, help="Consumer-collected evidence; required for cited responses")
    parser.add_argument("--run-id", required=True, help="Current run identifier supplied independently by the consumer")
    parser.add_argument("--enabled-layers", nargs="*", choices=("microsoft", "community", "custom"), default=["microsoft", "community", "custom"], help="Consumer configuration; an empty list disables every layer")
    args = parser.parse_args()
    try:
        errors = validate_response(strict_json(args.response),
            question=args.question_file.read_bytes().decode("utf-8-sig"), root=args.root,
            evidence=strict_json(args.read_evidence) if args.read_evidence else None,
            run_id=args.run_id, enabled_layers=args.enabled_layers)
    except (OSError, ValueError) as error:
        print(json.dumps({"valid": False, "errors": [str(error)]}))
        return 2
    print(json.dumps({"valid": not errors, "errors": errors}))
    return int(bool(errors))


if __name__ == "__main__":
    raise SystemExit(main())
