---
bc-version: [all]
domain: style
keywords: [label, textconst, suffix, msg, err, qst, tok, lbl, txt, aa0074]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Suffix every Label and TextConst with its approved usage tag

## Description

CodeCop rule AA0074 requires every Label and TextConst to carry a suffix indicating how the value is consumed: `Msg` for Message calls, `Err` for Error calls, `Qst` for Confirm or StrMenu prompts, `Tok` for locked tokens (URLs, JSON keys, short literals with `Locked = true`), `Lbl` for captions and tooltips, and `Txt` for telemetry strings. The suffix is not decoration — it is how the compiler, linter, and reviewer detect misuse (a `Tok` value passed to `Error`, a `Msg` used as an error label). The cost of adopting the convention is one short suffix per declaration; the cost of ignoring it is that every reviewer has to inspect every call site to judge appropriateness.

## Best Practice

Name every Label and TextConst with one of `Msg`, `Err`, `Qst`, `Tok`, `Lbl`, or `Txt` at the end. Pick the suffix that matches the consuming call, not the look of the string. When multiple suffixes are grammatically valid (`Tok` vs `Lbl` for a short caption on a locked token) the choice is a judgment call; the violation is missing a suffix or using one inconsistent with the call site.

See sample: `apply-approved-label-suffixes.good.al`.

## Anti Pattern

`CannotDeleteLine: Label 'Cannot delete this line.';` — no suffix, used with Error. `Text000: Label 'Update complete';` — generic name with no suffix at all. `WrongSuffixTok: Label 'Customer %1 not found.'` used with Error — a Tok suffix on an error label.

See sample: `apply-approved-label-suffixes.bad.al`.
