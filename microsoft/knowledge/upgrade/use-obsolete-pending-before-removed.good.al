codeunit 50817 "Upgrade Sample Obsolete Good"
{
    [Obsolete('Use CalculateNetAmountV2 for the updated rounding semantics.', '28.0')]
    procedure CalculateNetAmount(Amount: Decimal): Decimal
    begin
        exit(Amount);
    end;

    procedure CalculateNetAmountV2(Amount: Decimal): Decimal
    begin
        exit(Amount);
    end;
}
