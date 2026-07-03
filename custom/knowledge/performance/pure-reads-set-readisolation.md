---
bc-version: [all]
domain: performance
keywords: [readisolation, readuncommitted, pure-read, get, findset, findfirst, findlast]
technologies: [al]
countries: [w1]
application-area: [all]
---

# Set ReadIsolation explicitly on pure reads

## Description

In TCOG apps, pure reads should set an explicit `ReadIsolation` on the record instance before the read operation. This makes the read semantics intentional instead of inheriting whatever isolation level happens to be active in the surrounding transaction or caller. For display, lookup, and calculation helpers that only read data and do not make decisions that require committed consistency, the default convention is `IsolationLevel::ReadUncommitted`.

## Best Practice

Before a pure read such as `Get`, `FindSet`, `FindFirst`, `FindLast`, or a read-only existence or aggregation call, set `Rec.ReadIsolation(IsolationLevel::ReadUncommitted);` on the specific record instance, then perform the read. Use a stronger isolation level only when the procedure's functional contract requires committed or repeatable data.

## Anti Pattern

A read-only helper performs `Get`, `FindSet`, or another pure read without setting `ReadIsolation` on the record variable first. The code works, but the locking and consistency behavior is left implicit and can drift with surrounding transaction context. On hot paths such as page calculations, lookups, and repeated helper calls, this creates inconsistent conventions and makes concurrency behavior harder to reason about.