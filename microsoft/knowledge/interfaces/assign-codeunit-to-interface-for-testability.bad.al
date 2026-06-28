codeunit 50217 "Standard Discount Calc Bad"
{
    procedure CalculateDiscount(Amount: Decimal): Decimal
    begin
        if Amount > 1000 then
            exit(Amount * 0.1);
        exit(0);
    end;
}

codeunit 50216 "Order Total Bad"
{
    // Anti-pattern: the dependency is a concrete codeunit type, so a test
    // cannot substitute a double - it always runs the production rule.
    var
        DiscountCalc: Codeunit "Standard Discount Calc Bad";

    procedure NetAmount(Amount: Decimal): Decimal
    begin
        exit(Amount - DiscountCalc.CalculateDiscount(Amount));
    end;
}
