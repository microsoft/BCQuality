---
bc-version: [all]
domain: style
keywords: [enum, option, integer, magic-number, variable-typing, field-typing]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A fixed set of named choices must use Enum, not a raw Integer

## Description

When a variable or field can only take on a fixed set of more than two
named, mutually exclusive states — a difficulty level, a document type, a
processing status — it must be typed as `Enum` (or `Option` when extending
an object that still uses the legacy type). Representing that same state
as a plain `Integer` and tracking the meaning of each value in a comment or
in the developer's head (`1 = Beginner, 2 = Intermediate, 3 = Advanced`) is a
magic-number anti-pattern: the compiler cannot catch an out-of-range value,
`CASE`/`IF` branches read as opaque numbers instead of names, and every call
site must either duplicate the numbering or trust a comment that can go
stale.

This is distinct from a true two-state choice — see
[[binary-choice-must-be-boolean]] — which should be `Boolean`, not an
`Enum`/`Option` with two members. The line is the state count: more than
two named states is an enumeration question, not a Boolean one.

## Best Practice

```al
enum 50100 "Course Difficulty"
{
    Extensible = true;
    value(0; Beginner) { }
    value(1; Intermediate) { }
    value(2; Advanced) { }
}

field(50; Difficulty; Enum "Course Difficulty")
{
}
...
case Difficulty of
    "Course Difficulty"::Beginner:
        Level := 'Beginner';
    "Course Difficulty"::Intermediate:
        Level := 'Intermediate';
    "Course Difficulty"::Advanced:
        Level := 'Advanced';
end;
```

## Anti Pattern

```al
field(50; Difficulty; Integer)
{
}
...
// 1 = Beginner, 2..5 = Intermediate boundary is fuzzy, 6+ = Advanced?
case Difficulty of
    1:
        Level := 'Beginner';
    2, 3:
        Level := 'Intermediate';
end;
```

A raw `Integer` standing in for a named set of states pushes the
documentation of what each value means into a comment, a wiki page, or a
developer's memory — none of which the compiler or a future maintainer can
rely on.
