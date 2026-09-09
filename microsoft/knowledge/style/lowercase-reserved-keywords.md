---
bc-version: [all]
domain: style
keywords: [reserved-keyword, lowercase, aa0241, codecop, if, then, begin]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reserved keywords are written in lowercase (CodeCop AA0241)

## Description

CodeCop AA0241 requires reserved AL keywords — `if`, `then`, `else`, `begin`, `end`, `var`, `procedure`, `local`, `internal`, `for`, `while`, `repeat`, `until`, `case`, `of`, `do`, `not`, `and`, `or`, `exit`, `break`, `skip`, `quit`, and the rest — to be lowercase. Old Navision and C/AL code used `IF…THEN…BEGIN…END` in uppercase, and that style still lingers in training data and legacy modules. New AL code is lowercase. The rule applies to keywords only — type names (`Record`, `Codeunit`, `Integer`), property names (`Caption`, `ToolTip`), and identifiers are unaffected.

Test codeunits that retain legacy uppercase forms (`OPENEDIT`, `ASSERTERROR`, `VALUE`) are an accepted exception: the test framework historically uses those identifiers and rewriting them brings no benefit. The rule applies to new code in modified lines, not to long-standing test patterns.

## Best Practice

Write keywords lowercase: `if Condition then begin … end;`, `repeat … until Found;`, `for i := 1 to N do …`. The standard AL formatter normalizes casing automatically.

See sample: [`lowercase-reserved-keywords.good.al`](lowercase-reserved-keywords.good.al).

## Anti Pattern

`IF Condition THEN BEGIN DoSomething(); END;`, `REPEAT GetNext(); UNTIL Found;`. Uppercase keywords trip AA0241 and signal C/AL-era code that has not been modernized.

See sample: [`lowercase-reserved-keywords.bad.al`](lowercase-reserved-keywords.bad.al).
