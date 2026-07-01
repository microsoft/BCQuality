---
bc-version: [all]
domain: performance
keywords: [setloadfields, partial-records, just-in-time-load, jit-load, round-trip, pass-by-value, enumerator]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Reading an unlisted field after SetLoadFields triggers a JIT load

> Contributions welcome — open a PR to refine or extend this article.

## Description

`SetLoadFields` loads only the named fields, but the trap is what happens when code later reads a field that was *not* listed: the platform silently issues a **just-in-time (JIT) load** — an implicit `Get` that fetches the missing field(s) in a second database round-trip. A single JIT load can erase the saving; the real danger is a JIT that repeats per record. The optimization is only a win if the listed set covers every field touched anywhere downstream, not just in the immediate code block.

## Best Practice

Before adding `SetLoadFields`, audit the *whole* access lifecycle of the record variable — every field read in the loop body, in called procedures, in `OnValidate`/`OnAfterGetRecord`, and in anything that receives the record — and list all of them via `SetLoadFields`/`AddLoadFields`. Be especially careful when passing a partial record **by value**: the copy does not share the load set and its enumerator is not updated, so a helper that reads an unlisted field re-triggers the JIT on *every* iteration. Pass by `var` where you can (a JIT then updates the enumerator, so later iterations don't re-load), or call `AddLoadFields` before passing by value. If you cannot enumerate the fields confidently, prefer not to call `SetLoadFields` at all. See the existing guidance on when partial records pay off (`use-setloadfields-for-partial-records`).

## Anti Pattern

Adding `SetLoadFields(Field1, Field2)` at the top of a loop, then reading `Field3` deeper in the body or inside a by-value helper. The code compiles and returns correct data, but pays a hidden JIT round-trip — and in the by-value case it repeats once per row, quietly reversing the gain. JIT loads also introduce `Inconsistent read` / record-modified race errors that a full non-partial load avoids. Reviewer signal: a `SetLoadFields` list that omits a field later read through that record variable, especially a record passed by value to a procedure that reads a field the caller never listed.
