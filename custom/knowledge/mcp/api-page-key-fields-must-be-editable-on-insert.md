# CURABIS MCP: ODataKeyFields Must Be Editable for Create Operations

## Core Principle

Fields declared in `ODataKeyFields` that identify the record must not have `Editable = false` when the API page allows insert. If they are read-only, the OData API rejects them as unknown properties on POST — the create operation fails and the caller receives a `BadRequest` error.

## Why This Happens

`Editable = false` on a page field removes the field from the OData write schema entirely. When a consumer POSTs a new record and includes the key field in the body, BC cannot match it to any writable property and rejects the request.

## Pattern to Avoid

```al
// WRONG: Key field marked Editable = false — cannot be set on create
field(projectNo; Rec."Project No.")
{
    Caption = 'projectNo';
    Editable = false;  // blocks insert via API
}
```

## Correct Pattern

```al
// CORRECT: No Editable = false — BC controls mutability after insert via ODataKeyFields
field(projectNo; Rec."Project No.")
{
    Caption = 'projectNo';
}
```

## Requirements

- Fields listed in `ODataKeyFields` must not carry `Editable = false` on pages where `InsertAllowed = true`
- Fields that should be read-only after creation but writable on insert need no special property — OData key semantics handle immutability after the record exists
- Non-key fields that are genuinely read-only may still use `Editable = false`

## Verification

On any API page with `InsertAllowed = true`, confirm that every field referenced in `ODataKeyFields` does not have `Editable = false` in its field definition. A create test via the OData endpoint is the definitive check.
