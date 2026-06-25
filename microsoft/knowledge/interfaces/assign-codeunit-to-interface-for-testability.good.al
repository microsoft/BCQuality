interface IDiscountCalculation
{
    procedure CalculateDiscount(Amount: Decimal): Decimal;
}

codeunit 50213 "Standard Discount Calc" implements IDiscountCalculation
{
    procedure CalculateDiscount(Amount: Decimal): Decimal
    begin
        // Production rule: 10% off amounts over 1000.
        if Amount > 1000 then
            exit(Amount * 0.1);
        exit(0);
    end;
}

codeunit 50214 "Test Discount Calc" implements IDiscountCalculation
{
    // Lightweight test double: a fixed, predictable value so a test can assert
    // order totals without depending on the production discount rule.
    procedure CalculateDiscount(Amount: Decimal): Decimal
    begin
        exit(100);
    end;
}

codeunit 50215 "Order Total"
{
    var
        DiscountCalc: Interface IDiscountCalculation;

    // Production wiring: a codeunit assigns directly to the interface variable.
    procedure UseProductionCalculation()
    var
        StdCalc: Codeunit "Standard Discount Calc";
    begin
        DiscountCalc := StdCalc;
    end;

    // Setter injection: a test passes "Test Discount Calc" instead, with no
    // enum and no change to the consumer. The dependency is an interface.
    procedure SetDiscountCalculation(NewDiscountCalc: Interface IDiscountCalculation)
    begin
        DiscountCalc := NewDiscountCalc;
    end;

    procedure NetAmount(Amount: Decimal): Decimal
    begin
        exit(Amount - DiscountCalc.CalculateDiscount(Amount));
    end;
}
