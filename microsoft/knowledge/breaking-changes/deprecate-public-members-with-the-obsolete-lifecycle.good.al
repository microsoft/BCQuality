codeunit 50305 "Net Amount Api Good"
{
    // Old name kept during the warning window. The tag records when obsoletion
    // began; a later release deletes the method after consumers have migrated.
    [Obsolete('Use CalculateNetAmount instead.', '25.0')]
    procedure CalcNet(GrossAmount: Decimal; TaxRate: Decimal): Decimal
    begin
        exit(CalculateNetAmount(GrossAmount, TaxRate));
    end;

    procedure CalculateNetAmount(GrossAmount: Decimal; TaxRate: Decimal): Decimal
    begin
        exit(GrossAmount / (1 + TaxRate));
    end;
}
