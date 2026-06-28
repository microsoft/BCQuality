codeunit 50301 "Discount Api Bad"
{
    // Breaking: a Rate parameter was added to a procedure that already shipped.
    // Every dependent extension that called CalculateDiscount(Amount) now fails
    // to compile until it is changed and recompiled.
    procedure CalculateDiscount(Amount: Decimal; Rate: Decimal): Decimal
    begin
        exit(Amount * Rate);
    end;
}
