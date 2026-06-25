interface IShippingRate
{
    procedure CalculateRate(Weight: Decimal): Decimal;
}

codeunit 50200 "Standard Shipping Rate" implements IShippingRate
{
    procedure CalculateRate(Weight: Decimal): Decimal
    begin
        exit(Weight * 1.5);
    end;
}

codeunit 50201 "Express Shipping Rate" implements IShippingRate
{
    procedure CalculateRate(Weight: Decimal): Decimal
    begin
        exit((Weight * 1.5) + 25);
    end;
}

enum 50202 "Shipping Method" implements IShippingRate
{
    Extensible = true;

    value(0; Standard)
    {
        Implementation = IShippingRate = "Standard Shipping Rate";
    }
    value(1; Express)
    {
        Implementation = IShippingRate = "Express Shipping Rate";
    }
}

codeunit 50203 "Shipping Charge"
{
    // Dispatch is automatic: assign the enum to the interface variable and call.
    // A new method = one new enum value + one impl codeunit, with no edit here.
    procedure GetRate(Method: Enum "Shipping Method"; Weight: Decimal): Decimal
    var
        RateProvider: Interface IShippingRate;
    begin
        RateProvider := Method;
        exit(RateProvider.CalculateRate(Weight));
    end;
}
