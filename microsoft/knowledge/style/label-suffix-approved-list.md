---
bc-version: [all]
domain: style
keywords: [label, textconst, suffix, aa0074, codecop, msg, err, qst, lbl, tok]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Use approved suffixes on Label and TextConst names (CodeCop AA0074)

## Description

CodeCop AA0074 flags `Label` and `TextConst` identifiers that do not end with an approved usage suffix. The suffix signals at the call site how the text is consumed and what translation behaviour it should get. The approved suffixes and their intended usage are: `Msg` for text shown via `Message()`; `Err` for text passed to `Error()`; `Qst` for text used with `Confirm` or `StrMenu`; `Lbl` for captions and tooltips; `Tok` for short tokens such as `'GET'`, `'PUT'`, `'HTTPS'`, GUIDs, or JSON/XML snippets that are not translated (typically with `Locked = true`); and `Txt` for general text including telemetry messages. A `Label` named `Text000` or `CannotDeleteLine` without a suffix violates the rule, regardless of how readable the prose is.

## Best Practice

Pick the suffix that matches the call where the label is consumed: `UpdateCompleteMsg` for `Message(...)`, `CustomerNotFoundErr` for `Error(...)`, `DeleteRecordQst` for `Confirm(...)`, `CustomerNameLbl` for tooltips and captions, `GetMethodTok` for locked tokens, `TelemetryDataTxt` for telemetry payloads. Suffix choices between `Tok`, `Lbl`, `Txt`, and `Msg` are judgment calls when the suffix is valid for the usage — what matters is that the suffix is on the approved list and matches the actual call.

See sample: [`label-suffix-approved-list.good.al`](label-suffix-approved-list.good.al).

## Anti Pattern

A `Label` declared with no suffix (`CannotDeleteLine: Label '…';`), a generic name (`Text000: Label '…';`), or a suffix that contradicts the usage (`WrongSuffixTok: Label 'Customer %1 not found.'` then passed to `Error()`). All three trip AA0074 or its reviewers and obscure the call-site contract.

See sample: [`label-suffix-approved-list.bad.al`](label-suffix-approved-list.bad.al).
