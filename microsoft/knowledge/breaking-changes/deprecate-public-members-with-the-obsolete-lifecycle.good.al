codeunit 50305 "Net Amount Api Good"
{
    // Old name kept and marked obsolete: callers still compile but get a warning
    // pointing at the replacement, with a tag recording the removal target version.
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
