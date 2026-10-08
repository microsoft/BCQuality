# Validating a knowledge response

`al-knowledge` returns guidance under the [DO knowledge-response contract](../skills/do.md#knowledge-response-contract).
The consumer checks its result before acceptance. This helper works independently
of consumer frameworks and hosts and does not execute the skill.

## Optional tooling and existing contracts

BCQuality already requires complete article reads and citation integrity under
READ and DO, and deterministic consumer validation for review reports. The new
knowledge-response contract applies these principles to knowledge consultation.

This Python helper and its read-evidence manifest are proposed optional tooling,
not existing runtime requirements or a pre-existing BCQuality evidence standard.
Python with `jsonschema` is needed only to run this implementation. Consumers may
validate the same contract with another implementation and their native tools.
They still must verify the exact question and complete citation reads in the
current run; they do not have to adopt this script or its manifest format.

The existing PowerShell retrieval helpers require PowerShell 7.2 or later. READ
already permits path discovery and native complete file reads when those helpers
or their prepared index are unavailable. The original repository's Python and
PyYAML frontmatter checks are development/CI tooling, not prerequisites for
question-only consultation.


In an inline host, the answering agent checks its own successful full-body tool
reads. This is self-attestation, not independent citation verification. A
consumer with a trusted read collector can independently check the evidence
using the optional validator. Neither mode proves that every claim correctly
interprets its sources. Report the mode used; never present inline checks as
independent verification.

## Consumer inputs

Preserve the raw response as one JSON object, without Markdown fences or extra
text. Save the exact bound question as UTF-8. Spaces and CRLF/LF line endings are
part of the question; the validator does not trim or normalize them. A UTF-8 BOM
is an encoding marker and not part of the bound question.

The consumer collects read evidence from successful tool results in the same
run, independently of the action's answer. A claim in `answer`, an attempted
tool call, an index row, or a displayed filename is insufficient. Mark an
article complete only after receiving its full body through EOF, and compute
its SHA-256 and UTF-8 byte count from the exact complete file bytes received.
Preserve source encoding and line endings when collecting that evidence.

The evidence file has this shape (values below are placeholders):

```json
{
  "runId": "consumer-assigned-run-id",
  "questionSha256": "sha256-of-the-exact-question-encoded-as-utf8",
  "reads": [
    {
      "path": "microsoft/knowledge/performance/use-setloadfields-for-partial-records.md",
      "complete": true,
      "bytes": 1234,
      "sha256": "sha256-of-the-complete-article-file-bytes"
    }
  ]
}
```

Use a consumer-assigned identifier for the current run. Supply it separately
to the validator and reject evidence from another run or question. Do not ask
the answering agent to invent this manifest. The validator trusts the evidence
collector; hashes and a boolean alone cannot independently prove a tool read.

## Run the checks

Install `jsonschema` in the consumer's Python environment if it is unavailable.
From the BCQuality root:

```powershell
python tools/validate_knowledge_response.py response.json `
  --root . --question-file question.txt `
  --read-evidence reads.json --run-id consumer-assigned-run-id
```

The tool checks the response schema, exact question, existing canonical citation
paths within the corpus, and complete-read evidence with matching current file
hashes and byte counts. A changed article, truncated read, missing evidence,
different-layer path with the same filename, or mismatched run is rejected.
The tool never repairs or rewrites the response.

Exit codes: `0` means these checks passed, `1` means validation failed, and `2`
means invalid JSON or an input/resource error prevented validation. Failed
validation is not a successful knowledge response. Preserve the raw payload and
record the validation errors separately. Do not accept or display its answer as
validated BCQuality guidance. A response with no citations does not need a read
manifest, but still must satisfy the schema and preserve the question.

Passing does not establish that every claim follows from its references, that
target applicability is correct, or that the corpus covers the question fully.
Those checks require the [READ rules](../skills/read.md) and actual execution
evidence. Catalog discovery and schema validity alone do not prove execution.

## Enabled layers

Supply the consumer configuration through `--enabled-layers microsoft community`
(or all three by default). An explicit empty list disables every layer.
Citations and layer-precedence suppressions must belong to enabled layers.
A `suppressed` entry with reason `configuration` may identify an existing
article in a disabled layer; it is an exclusion record, never supporting evidence.
All these paths must be canonical existing corpus files.

## Regression tests

```powershell
python .github/scripts/test_knowledge_response.py
python .github/scripts/test_knowledge_response_semantics.py
```

The first checks JSON Schema cases. The second uses fixture evidence to exercise
question fidelity, complete reads, current body hashes, path identity, and CLI
behavior. Fixture tests are not live host executions.
