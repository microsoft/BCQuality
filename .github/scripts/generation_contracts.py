"""Strict JSON Schema and semantic validation for AL generation contracts."""
from __future__ import annotations

import json
import re
import uuid
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

try:
    from jsonschema import Draft202012Validator, FormatChecker
except ImportError:  # Existing CI installs only PyYAML; use the contract-focused fallback.
    Draft202012Validator = None
    FormatChecker = None


MAX_REQUIREMENT_BYTES = 1_048_576
MAX_ARTIFACT_BYTES = 262_144
MAX_TOTAL_ARTIFACT_BYTES = 4_194_304


class DuplicateKeyError(ValueError):
    pass


def _reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise DuplicateKeyError(f"duplicate JSON key: {key}")
        result[key] = value
    return result


def load_bounded_json(path: Path, max_bytes: int = MAX_REQUIREMENT_BYTES) -> Any:
    raw = path.read_bytes()
    if len(raw) > max_bytes:
        raise ValueError(f"JSON file exceeds {max_bytes} bytes")
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as exc:
        raise ValueError("JSON file is not UTF-8") from exc
    try:
        return json.loads(text, object_pairs_hook=_reject_duplicate_keys)
    except (json.JSONDecodeError, DuplicateKeyError) as exc:
        raise ValueError(f"malformed JSON: {exc}") from exc


def load_schema(path: Path) -> dict[str, Any]:
    schema = load_bounded_json(path, max_bytes=2_097_152)
    if not isinstance(schema, dict):
        raise ValueError(f"schema must be a JSON object: {path}")
    if Draft202012Validator is not None:
        Draft202012Validator.check_schema(schema)
    else:
        _check_schema_structure(schema, schema)
    return schema


def schema_errors(schema: dict[str, Any], instance: Any) -> list[str]:
    if Draft202012Validator is not None:
        validator = Draft202012Validator(schema, format_checker=FormatChecker())
        return [error.message for error in sorted(validator.iter_errors(instance), key=lambda e: list(e.path))]
    return _fallback_schema_errors(schema, instance)


def _resolve_ref(root: dict[str, Any], reference: str) -> dict[str, Any]:
    if not reference.startswith("#/"):
        raise ValueError(f"fallback validator supports only local references: {reference}")
    value: Any = root
    for token in reference[2:].split("/"):
        token = token.replace("~1", "/").replace("~0", "~")
        if not isinstance(value, dict) or token not in value:
            raise ValueError(f"unresolvable schema reference: {reference}")
        value = value[token]
    if not isinstance(value, dict):
        raise ValueError(f"schema reference is not an object: {reference}")
    return value


def _check_schema_structure(schema: dict[str, Any], root: dict[str, Any]) -> None:
    if "$ref" in schema:
        _resolve_ref(root, schema["$ref"])
    if "pattern" in schema:
        re.compile(schema["pattern"])
    for key in ("properties", "$defs"):
        for child in schema.get(key, {}).values():
            _check_schema_structure(child, root)
    for key in ("items", "contains", "if", "then", "else"):
        child = schema.get(key)
        if isinstance(child, dict):
            _check_schema_structure(child, root)
    for key in ("allOf", "anyOf"):
        for child in schema.get(key, []):
            _check_schema_structure(child, root)


def _type_matches(expected: str, value: Any) -> bool:
    return {
        "object": isinstance(value, dict),
        "array": isinstance(value, list),
        "string": isinstance(value, str),
        "integer": isinstance(value, int) and not isinstance(value, bool),
        "number": isinstance(value, (int, float)) and not isinstance(value, bool),
        "boolean": isinstance(value, bool),
        "null": value is None,
    }.get(expected, False)


def _fallback_schema_errors(
    schema: dict[str, Any],
    instance: Any,
    *,
    root: dict[str, Any] | None = None,
    path: str = "$",
) -> list[str]:
    root = root or schema
    if "$ref" in schema:
        return _fallback_schema_errors(_resolve_ref(root, schema["$ref"]), instance, root=root, path=path)

    errors: list[str] = []
    if "anyOf" in schema:
        branch_errors = [
            _fallback_schema_errors(child, instance, root=root, path=path)
            for child in schema["anyOf"]
        ]
        if all(branch_errors):
            errors.append(f"{path}: does not match any allowed schema")
            return errors
    for child in schema.get("allOf", []):
        errors.extend(_fallback_schema_errors(child, instance, root=root, path=path))

    condition = schema.get("if")
    if condition is not None:
        matches = not _fallback_schema_errors(condition, instance, root=root, path=path)
        selected = schema.get("then") if matches else schema.get("else")
        if selected is not None:
            errors.extend(_fallback_schema_errors(selected, instance, root=root, path=path))

    expected_type = schema.get("type")
    if expected_type and not _type_matches(expected_type, instance):
        errors.append(f"{path}: expected {expected_type}")
        return errors
    if "const" in schema and instance != schema["const"]:
        errors.append(f"{path}: expected constant {schema['const']!r}")
    if "enum" in schema and instance not in schema["enum"]:
        errors.append(f"{path}: value is not in the allowed enum")

    if isinstance(instance, dict):
        required = schema.get("required", [])
        for key in required:
            if key not in instance:
                errors.append(f"{path}: missing required property {key!r}")
        properties = schema.get("properties", {})
        for key, value in instance.items():
            if key in properties:
                errors.extend(_fallback_schema_errors(properties[key], value, root=root, path=f"{path}.{key}"))
            elif schema.get("additionalProperties") is False:
                errors.append(f"{path}: unexpected property {key!r}")

    if isinstance(instance, list):
        if len(instance) < schema.get("minItems", 0):
            errors.append(f"{path}: too few items")
        if "maxItems" in schema and len(instance) > schema["maxItems"]:
            errors.append(f"{path}: too many items")
        if schema.get("uniqueItems"):
            encoded = [json.dumps(item, sort_keys=True, separators=(",", ":")) for item in instance]
            if len(encoded) != len(set(encoded)):
                errors.append(f"{path}: items must be unique")
        item_schema = schema.get("items")
        if isinstance(item_schema, dict):
            for index, value in enumerate(instance):
                errors.extend(_fallback_schema_errors(item_schema, value, root=root, path=f"{path}[{index}]"))
        contains = schema.get("contains")
        if isinstance(contains, dict) and not any(
            not _fallback_schema_errors(contains, value, root=root, path=f"{path}[{index}]")
            for index, value in enumerate(instance)
        ):
            errors.append(f"{path}: no item matches contains")

    if isinstance(instance, str):
        if len(instance) < schema.get("minLength", 0):
            errors.append(f"{path}: string is too short")
        if "maxLength" in schema and len(instance) > schema["maxLength"]:
            errors.append(f"{path}: string is too long")
        if "pattern" in schema and re.search(schema["pattern"], instance) is None:
            errors.append(f"{path}: string does not match required pattern")
        if schema.get("format") == "uuid":
            try:
                uuid.UUID(instance)
            except ValueError:
                errors.append(f"{path}: invalid UUID")
        if schema.get("format") == "uri":
            parsed = urlparse(instance)
            if not parsed.scheme or not parsed.netloc:
                errors.append(f"{path}: invalid URI")

    if isinstance(instance, (int, float)) and not isinstance(instance, bool):
        if "minimum" in schema and instance < schema["minimum"]:
            errors.append(f"{path}: value is below minimum")
        if "maximum" in schema and instance > schema["maximum"]:
            errors.append(f"{path}: value exceeds maximum")

    return errors


def _canonical_path_error(value: Any, *, allow_dot: bool = False, require_al: bool = False) -> str | None:
    if not isinstance(value, str) or not value:
        return "must be a non-empty string"
    if allow_dot and value == ".":
        return None
    if value.startswith("/") or "\\" in value or (len(value) >= 2 and value[1] == ":"):
        return "must be a project-relative forward-slash path"
    if value.endswith("/") or "//" in value:
        return "must be canonical without empty path segments"
    parts = value.split("/")
    if not parts or any(part in {"", ".", ".."} for part in parts):
        return "must not contain dot or traversal segments"
    if any(part == ".git" for part in parts):
        return "must not address .git"
    if require_al and not value.endswith(".al"):
        return "must end with case-sensitive .al"
    return None


def _is_under(path: str, root: str) -> bool:
    if root == ".":
        return True
    return path.startswith(f"{root}/")


def _in_id_ranges(object_id: int, ranges: list[dict[str, int]]) -> bool:
    return any(item["from"] <= object_id <= item["to"] for item in ranges)


def validate_requirement_semantics(
    document: dict[str, Any],
    *,
    existing_paths: set[str] | None = None,
) -> list[str]:
    errors: list[str] = []
    app_root = document.get("app-root")
    if error := _canonical_path_error(app_root, allow_dot=True):
        errors.append(f"app-root {error}")
        return errors

    requested = document.get("requested-artifacts", [])
    allowlist = document.get("related-file-allowlist", [])
    requested_paths = [item.get("path") for item in requested if isinstance(item, dict)]
    if len(requested_paths) != len(set(requested_paths)):
        errors.append("requested artifact paths must be unique")
    if len(allowlist) != len(set(allowlist)):
        errors.append("related-file-allowlist paths must be unique")

    for path in requested_paths:
        if error := _canonical_path_error(path, require_al=True):
            errors.append(f"requested artifact path {path!r} {error}")
        elif not _is_under(path, app_root):
            errors.append(f"requested artifact path {path!r} is outside app-root {app_root!r}")
        if existing_paths is not None and path in existing_paths:
            errors.append(f"requested artifact path {path!r} already exists")

    for path in allowlist:
        if error := _canonical_path_error(path):
            errors.append(f"allowlist path {path!r} {error}")

    ranges = document.get("target", {}).get("app", {}).get("id-ranges", [])
    ordered = sorted(ranges, key=lambda item: (item.get("from", 0), item.get("to", 0)))
    previous_to = 0
    for item in ordered:
        start, end = item.get("from"), item.get("to")
        if not isinstance(start, int) or not isinstance(end, int):
            continue
        if start > end:
            errors.append(f"ID range {start}-{end} is inverted")
        if start <= previous_to:
            errors.append(f"ID range {start}-{end} overlaps another range")
        previous_to = max(previous_to, end)

    object_ids = [item.get("object-id") for item in requested if isinstance(item, dict) and "object-id" in item]
    if len(object_ids) != len(set(object_ids)):
        errors.append("requested object IDs must be unique")
    for object_id in object_ids:
        if isinstance(object_id, int) and not _in_id_ranges(object_id, ranges):
            errors.append(f"requested object ID {object_id} is outside target id-ranges")

    dependencies = document.get("target", {}).get("app", {}).get("dependencies", [])
    dependency_ids = [item.get("id") for item in dependencies if isinstance(item, dict)]
    if len(dependency_ids) != len(set(dependency_ids)):
        errors.append("dependency IDs must be unique")

    return errors


def validate_report_semantics(
    document: dict[str, Any],
    *,
    requirement: dict[str, Any] | None = None,
) -> list[str]:
    errors: list[str] = []
    artifacts = document.get("artifacts", [])
    omitted = document.get("omitted-guidance", [])
    summary = document.get("summary", {})
    coverage = summary.get("coverage", {})

    paths = [artifact.get("path") for artifact in artifacts if isinstance(artifact, dict)]
    ids = [artifact.get("object-id") for artifact in artifacts if isinstance(artifact, dict)]
    if len(paths) != len(set(paths)):
        errors.append("artifact paths must be unique")
    if len(ids) != len(set(ids)):
        errors.append("artifact object IDs must be unique")

    content_sizes: list[int] = []
    for artifact in artifacts:
        if not isinstance(artifact, dict):
            continue
        path = artifact.get("path")
        if error := _canonical_path_error(path, require_al=True):
            errors.append(f"artifact path {path!r} {error}")
        content = artifact.get("content")
        if isinstance(content, str):
            size = len(content.encode("utf-8"))
            content_sizes.append(size)
            if size > MAX_ARTIFACT_BYTES:
                errors.append(f"artifact {path!r} exceeds {MAX_ARTIFACT_BYTES} UTF-8 bytes")

    total_size = sum(content_sizes)
    if total_size > MAX_TOTAL_ARTIFACT_BYTES:
        errors.append(f"artifact content exceeds {MAX_TOTAL_ARTIFACT_BYTES} total UTF-8 bytes")
    if summary.get("artifact-count") != len(artifacts):
        errors.append("summary.artifact-count does not match artifacts")
    if summary.get("total-content-bytes") != total_size:
        errors.append("summary.total-content-bytes does not match UTF-8 artifact content")
    if coverage.get("omitted-count") != len(omitted):
        errors.append("summary.coverage.omitted-count does not match omitted-guidance")
    if coverage.get("opened-article-count", 0) > coverage.get("worklist-count", 0):
        errors.append("opened-article-count exceeds worklist-count")
    if coverage.get("worklist-count", 0) > coverage.get("relevant-count", 0):
        errors.append("worklist-count exceeds relevant-count")
    if coverage.get("relevant-count", 0) > coverage.get("candidate-count", 0):
        errors.append("relevant-count exceeds candidate-count")
    if coverage.get("opened-article-count") != coverage.get("worklist-count"):
        errors.append("opened-article-count must equal worklist-count")
    if coverage.get("relevant-count") != coverage.get("worklist-count", 0) + coverage.get("omitted-count", 0):
        errors.append("relevant-count must equal worklist-count plus omitted-count")
    if omitted and document.get("outcome") != "partial":
        errors.append("any omitted guidance requires outcome partial")

    revision = document.get("knowledge-revision", {}).get("commit-sha")
    for artifact in artifacts:
        if not isinstance(artifact, dict):
            continue
        for key in ("article-references", "good-sample-references"):
            for reference in artifact.get(key, []):
                if reference.get("sha") != revision:
                    errors.append(f"{key} reference SHA must equal knowledge-revision.commit-sha")
    for item in document.get("applied-guidance", []) + omitted:
        if item.get("reference", {}).get("sha") != revision:
            errors.append("guidance reference SHA must equal knowledge-revision.commit-sha")
    for item in document.get("suppressed", []):
        if item.get("reference", {}).get("sha") != revision:
            errors.append("suppressed reference SHA must equal knowledge-revision.commit-sha")
        if item.get("superseded-by") and item["superseded-by"].get("sha") != revision:
            errors.append("superseding reference SHA must equal knowledge-revision.commit-sha")

    if requirement is not None:
        app_root = requirement.get("app-root", "")
        requested = {
            item["path"]: item
            for item in requirement.get("requested-artifacts", [])
            if isinstance(item, dict) and "path" in item
        }
        ranges = requirement.get("target", {}).get("app", {}).get("id-ranges", [])
        for artifact in artifacts:
            path = artifact.get("path")
            request = requested.get(path)
            if not _is_under(path, app_root):
                errors.append(f"artifact path {path!r} is outside app-root {app_root!r}")
            if request is None:
                errors.append(f"artifact path {path!r} was not requested")
            elif artifact.get("object-type") != request.get("object-type"):
                errors.append(f"artifact {path!r} object type differs from request")
            elif artifact.get("object-name") != request.get("object-name"):
                errors.append(f"artifact {path!r} object name differs from request")
            object_id = artifact.get("object-id")
            if request is not None and request.get("object-id") is not None and object_id != request["object-id"]:
                errors.append(f"artifact {path!r} object ID differs from request")
            if isinstance(object_id, int) and not _in_id_ranges(object_id, ranges):
                errors.append(f"artifact object ID {object_id} is outside target id-ranges")

        artifact_path_set = set(paths)
        for item in document.get("applied-guidance", []):
            for path in item.get("artifact-paths", []):
                if path not in artifact_path_set:
                    errors.append(f"applied-guidance references absent artifact {path!r}")

    return errors
