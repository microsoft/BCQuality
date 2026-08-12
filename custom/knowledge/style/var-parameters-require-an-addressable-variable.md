---
bc-version: [all]
domain: style
keywords: [var-parameter, by-reference, pass-by-reference, literal, constant, compile-error, procedure-call]
technologies: [al]
countries: [w1]
application-area: [all]
---

# A `var` parameter must be called with a variable, never a literal or expression

## Description

When a procedure declares a parameter with `var` — `procedure DoSomething(var Result: Text)` —
that parameter is passed by reference: the callee writes back into the
caller's own memory location. This means the argument at the call site
must be an actual variable, something with an address. A string literal, a
numeric constant, or a computed expression has no address to write back
to, so passing one to a `var` parameter fails to compile.

This is a known failure mode when generating AL code without tracking
which parameters on a called procedure are declared `var`: a call that
would be valid for a by-value parameter (`DoSomething('Hello')`,
`DoSomething(SomeText + Suffix)`) is invalid the moment that same parameter
position is `var`. Before writing a call, check the callee's signature for
`var` on each parameter position being supplied a literal or expression —
if present, a variable declared in the caller's own scope must be used
instead, even if that means declaring a throwaway local variable just to
hold the value.

## Best Practice

```al
procedure GetCustomerName(CustomerNo: Code[20]; var Name: Text[100])
begin
    if Customer.Get(CustomerNo) then
        Name := Customer.Name;
end;

var
    CustName: Text[100];
...
GetCustomerName('10000', CustName);
```

## Anti Pattern

```al
procedure GetCustomerName(CustomerNo: Code[20]; var Name: Text[100])
begin
    if Customer.Get(CustomerNo) then
        Name := Customer.Name;
end;
...
GetCustomerName('10000', 'placeholder'); // compile error: cannot pass a literal to a var parameter
GetCustomerName('10000', CustName + ''); // compile error: an expression is not addressable either
```

Both anti-pattern calls fail to compile with an error to the effect of "a
`var` parameter requires a variable" — the fix is always to declare (or
reuse) a variable for that argument position, never to reach for a literal
or expression because the value "looks" like what the parameter should
receive.
