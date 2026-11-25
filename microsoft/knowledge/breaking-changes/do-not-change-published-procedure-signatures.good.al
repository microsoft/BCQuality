codeunit 50300 "Discount Api Good"
{
    // Published contract — signature kept exactly as it shipped.
    procedure CalculateDiscount(Amount: Decimal): Decimal
    begin
        exit(Amount * 0.05);
    end;

    // New capability uses a separate procedure, preserving existing callers.
    // Naming a previously unnamed return value is also safe.
    procedure CalculateDiscountWithRate(Amount: Decimal; Rate: Decimal) Discount: Decimal
    begin
        Discount := Amount * Rate;
    end;
}

codeunit 50301 "Ledger Entry Api Good"
{
    // Previously Integer parameter, local, and return; widened on runtime 18.0+.
    // Integer consumers must still handle overflow when using the larger range.
    procedure GetNextEntryNo(LastEntryNo: BigInteger): BigInteger
    var
        NextEntryNo: BigInteger;
    begin
        NextEntryNo := LastEntryNo + 1;
        exit(NextEntryNo);
    end;

    // Widening preserves the existing var modifier.
    procedure AdvanceEntryNo(var EntryNo: BigInteger)
    begin
        EntryNo += 1;
    end;
}
