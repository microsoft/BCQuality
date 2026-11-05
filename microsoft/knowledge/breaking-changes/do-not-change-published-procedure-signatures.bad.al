codeunit 50301 "Discount Api Bad"
{
    // Breaking: a Rate parameter was added to a procedure that already shipped.
    // Every dependent extension that called CalculateDiscount(Amount) now fails
    // to compile until it is changed and recompiled.
    procedure CalculateDiscount(Amount: Decimal; Rate: Decimal): Decimal
    begin
        exit(Amount * Rate);
    end;

    // Breaking: this procedure already returned a value, and that existing
    // return type was retyped from Integer to Text. Callers that assigned the
    // old Integer result to an Integer variable now fail to compile. This is
    // different from adding a return value to a previously void procedure,
    // which is additive and not flagged.
    procedure GetStatusCode(): Text
    begin
        exit('OK');
    end;
}
