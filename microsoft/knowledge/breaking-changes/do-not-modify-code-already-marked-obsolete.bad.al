codeunit 50316 "Pricing Api Bad"
{
    // Anti-pattern: new surcharge logic is added inside a procedure already marked
    // obsolete, and inside a #if not CLEAN25 block. Both are scheduled for removal,
    // so this behaviour disappears the moment CLEAN25 is enabled.
    [Obsolete('Use GetUnitPrice instead.', '25.0')]
    procedure GetPrice(ItemNo: Code[20]): Decimal
    var
        Price: Decimal;
    begin
        Price := 100;
#if not CLEAN25
        Price += CalculateSurcharge(ItemNo);
#endif
        exit(Price);
    end;

    local procedure CalculateSurcharge(ItemNo: Code[20]): Decimal
    begin
        exit(5);
    end;
}
