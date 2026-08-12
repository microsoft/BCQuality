---
bc-version: [all]
domain: style
keywords: [boolean, option, yes-no, magic-number, variable-typing, field-typing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Binary yes/no choices must be typed as Boolean, not Option or Integer

## Description

When a field or variable represents exactly two states — yes/no, on/off,
active/inactive, blocked/not blocked — it must be typed `Boolean`. Modeling
that same two-state choice as an `Option`/`Enum` with two members, or as an
`Integer` with two magic-number values (0/1), adds a layer of indirection a
reader has to resolve before understanding the code, and it invites a
three-way branch (`if X = 0 then ... else if X = 1 then ...`) where a simple
`if X then ...` would do.

This is distinct from a genuine multi-value choice — see
[[fixed-choice-set-must-use-enum-not-integer]] — where more than two named
states legitimately call for `Enum`. The line is the state count: exactly
two mutually exclusive states is a Boolean question, not an enumeration.

## Best Practice

```al
field(50; Blocked; Boolean)
{
}

var
    IsOverdue: Boolean;
...
IsOverdue := DueDate < Today;
if IsOverdue then
    ...
```

## Anti Pattern

```al
field(50; Status; Option)
{
    OptionMembers = Active,Blocked;
}

var
    OverdueFlag: Integer; // 0 = No, 1 = Yes
...
if OverdueFlag = 1 then
    ...
```

An `Option`/`Integer` standing in for a true yes/no forces every caller to
remember which value means what, and it leaves room for a third, meaningless
value that a `Boolean` cannot represent.
