---
applyTo: '**/*.al'
---

# RNB AL Development Guidelines

Apply these organization conventions when authoring or changing AL. They complement the BCQuality review knowledge and the consuming app's compiler, analyzers, and tests; they do not replace them. Company-specific review rules are in `custom/knowledge/`.

## Naming and captions

- Use meaningful English identifiers.
- Prefix new AL object names with `RNB `.
- Prefix new fields in table extensions with `RNB `.
- Prefix new controls, actions, and parts with `RNB `, except when they are declared on a new page or report. The page or report object name still uses the prefix.
- For each new user-facing caption that does not inherit a suitable caption, provide English text and the company's Dutch metadata comment, for example `Caption = 'Source code', Comment = '[NLD = Broncode]'`. Follow the repository's localization workflow so the Dutch translation is present in the shipped translation files; the comment alone is not a platform translation.
- Do not add a redundant page-level caption when a bound table field already supplies the intended caption.

## Data, access, and UI

- Never hardcode credentials, tokens, or secrets.
- Do not present calculated FlowFields as editable inputs. FlowFilters are user-configurable filters where the workflow requires them; do not blanket-set them to `Editable = false`.
- Give normal table fields an intentional `DataClassification`; do not leave new fields as `ToBeClassified`. Do not set `DataClassification` on FlowFields or FlowFilters; follow BCQuality's privacy guidance for inherited classification.
- Set `ApplicationArea` on new user-facing controls or at a supported object level so the controls are discoverable in the intended application area.
- Add each new grantable AL object to at least one appropriate permission set. This company policy does not apply to object extensions or enum objects; permission-set definitions are not themselves permission targets.
- Keep page code focused on presentation and interaction. Put reusable business operations in codeunits and keep data invariants with the table or domain that owns them.
- Use temporary tables for record-shaped data that must not be persisted. Do not make persistent data temporary as a shortcut.

## Performance and correctness

- For existence checks, use an existence-oriented API such as `IsEmpty` or `IsRecord` where it expresses the intent; do not retrieve and iterate rows merely to learn whether one exists.
- Filter record sets before iteration. Use `FindSet(false)` for read-only iteration and `FindSet(true)` when the loop will modify or delete the traversed records.
- Use `SetAutoCalcFields` when a loop needs the same FlowFields for each row. Consider `SetLoadFields` for read-only, non-temporary records when only some normal fields are needed. Do not apply partial loading to records that will be written, passed to `TransferFields`, or copied as complete records.
- Avoid duplicating logic; move genuinely reusable operations into a suitable codeunit procedure.
- Guard division when a zero denominator is possible and choose a fallback that matches the business meaning. Use a sufficiently wide numeric type and validate bounds when inputs or accumulated results can exceed the type's range.
- Validate external or user-provided values before converting them or using them as collection indexes. AL records are not nullable object references: check that a record exists when the business operation requires an existing row, not merely before reading a field from the record variable.
- Follow BCQuality's existing domain articles for performance, privacy, security, and UI behavior rather than adding generic checks that duplicate analyzer diagnostics or platform defaults.

## Declarations and review

- Order variables by type to satisfy AA0021: `Record`, `Report`, `Codeunit`, `XmlPort`, `Page`, `Query`, `Notification`, `BigText`, `DateFormula`, `RecordId`, `RecordRef`, `FieldRef`, `FilterPageBuilder`. Put other variable types after these; do not sort those remaining types.
- Run the consuming app's configured AL analyzers and tests. Do not turn deterministic compiler or analyzer diagnostics into duplicate prose-only review rules.
- When reviewing AL, use the applicable BCQuality review skill and its required findings-report contract. Do not replace that contract with informal severity categories.