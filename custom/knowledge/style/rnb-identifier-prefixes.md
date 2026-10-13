---
bc-version: [all]
domain: style
keywords: [rnb, prefix, identifiers, object-name, table-extension, control-name]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Prefix New AL Identifiers with RNB

## Description

RNB projects use a company prefix to distinguish their AL objects and extension members from platform and other-app identifiers. This is an organization convention, not a Business Central platform requirement. Apply it to newly introduced identifiers; do not report unchanged legacy names solely to expand the scope of a review.

## Best Practice

Prefix each new AL object name and each new field declared in a table extension with `RNB `. Prefix new controls, actions, and parts with `RNB ` unless they are declared on an entirely new page or report. The page or report object's own name still requires the prefix. Keep existing identifiers unchanged unless the change already renames them for another reason.

## Anti Pattern

A newly introduced object name, table-extension field name, or in-scope control/action/part name lacks the `RNB ` prefix. Do not report controls, actions, or parts declared on a new page or report, or unchanged identifiers outside the change scope.

See sample: [`rnb-identifier-prefixes.good.al`](rnb-identifier-prefixes.good.al) and [`rnb-identifier-prefixes.bad.al`](rnb-identifier-prefixes.bad.al).

## Applies to

This is RNB organization policy and is not a platform-endorsed naming rule.