codeunit 50306 "Net Amount Api Bad"
{
    // Breaking: the published CalcNet procedure was renamed outright with no
    // deprecation window and no [Obsolete] marker. Every extension that called
    // CalcNet breaks the instant it consumes this version.
    procedure CalculateNetAmount(GrossAmount: Decimal; TaxRate: Decimal): Decimal
    begin
        exit(GrossAmount / (1 + TaxRate));
    end;
}
