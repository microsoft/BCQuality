codeunit 50315 "Pricing Api Good"
{
    // Obsolete member left untouched — it only forwards to the replacement and
    // gains no new logic.
    [Obsolete('Use GetUnitPrice instead.', '25.0')]
    procedure GetPrice(ItemNo: Code[20]): Decimal
    begin
        exit(GetUnitPrice(ItemNo));
    end;

    // New behaviour is built on the supported replacement, not on the obsolete member.
    procedure GetUnitPrice(ItemNo: Code[20]): Decimal
    begin
        exit(CalculateBasePrice(ItemNo) + CalculateSurcharge(ItemNo));
    end;

    local procedure CalculateBasePrice(ItemNo: Code[20]): Decimal
    begin
        exit(100);
    end;

    local procedure CalculateSurcharge(ItemNo: Code[20]): Decimal
    begin
        exit(5);
    end;
}
