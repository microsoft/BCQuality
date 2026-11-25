---
bc-version: [all]
domain: breaking-changes
keywords: [tableextension, pageextension, reportextension, same-app, extraction, procedure, variable, codeunit, relocation, false-positive]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Same-app extraction into table, page, or report extensions is not a breaking change

## Description

The platform supports extracting fields, procedures, and variables from a table into a `tableextension` of that same table within the same app, without making the extraction itself a breaking change. The same principle applies to pages and reports through their corresponding `pageextension` and `reportextension` objects. These extension objects contribute to the original object's effective contract; the declaration disappearing from the base definition is not proof that the member disappeared for consumers. Moving a published procedure from one codeunit to another is different: there is no codeunit-extension concept, so deleting the old entry point breaks callers bound to the original codeunit, even within the same app.

## Best Practice

Read both sides of the diff and compare the resulting effective object, not just the base object's source file. Recognize a supported extraction only when:

- The base object and destination extension belong to the same app identity; sharing a repository, publisher, or namespace is not enough.
- The destination is the matching extension kind and `extends` the original table, page, or report, not another base object.
- The members retain their contracts: field IDs and names, types, procedure names/signatures, variable names/types/visibility, and any externally visible control or dataset identity. Preserve state, initialization, and trigger behavior as well.

For that extraction alone, do not report deletion, illegal field-ID reuse, or a breaking procedure move, and do not demand obsoletion staging, compatibility wrappers, a replacement field, or data migration. Existing record/page/report callers continue to address the original effective object. A change to a signature, access, field ID, or behavior made alongside the extraction must still be reviewed separately.

Apply this rule where the target platform/toolchain supports same-app member extraction. For older targets, verify that support rather than inventing a minimum runtime version or treating the mere existence of extension objects as proof of support. Moving members between different apps is outside this exception and must follow the applicable ownership/dependency migration rules.

For codeunit-to-codeunit refactoring, preserve the original published procedure as a forwarding entry point if callers must remain compatible. If retiring that entry point, use the [procedure deprecation lifecycle](deprecate-public-members-with-the-obsolete-lifecycle.md). Moving implementation behind an unchanged entry point is not the same as removing the caller's API.

See sample: [`relocating-a-field-to-a-tableextension-is-not-a-deletion.good.al`](relocating-a-field-to-a-tableextension-is-not-a-deletion.good.al).

## Anti Pattern

Reporting a field, procedure, or variable as deleted solely because it moved from a table, page, or report into its corresponding extension in the same app, with its effective contract preserved. Requiring an obsolete duplicate for that supported extraction is a false positive.

Conversely, removing a published procedure from codeunit A and adding it to codeunit B, then claiming the move is compatible because the name, signature, and app are unchanged. Existing calls through codeunit A no longer resolve; codeunit B does not extend A. Private implementation-only refactoring is not automatically a published API break.

See sample: [`relocating-a-field-to-a-tableextension-is-not-a-deletion.bad.al`](relocating-a-field-to-a-tableextension-is-not-a-deletion.bad.al).

## References

Compatibility basis: platform behavior confirmed for this contribution. The public object references below describe the extension model, not an introduction version for same-app extraction.

- [Table extension objects](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-table-ext-object).
- [Page extension objects](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-page-ext-object).
- [Report extension objects](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-report-ext-object).
- [Codeunit objects and calls bound to a codeunit](https://learn.microsoft.com/en-us/dynamics365/business-central/dev-itpro/developer/devenv-codeunit-object).
