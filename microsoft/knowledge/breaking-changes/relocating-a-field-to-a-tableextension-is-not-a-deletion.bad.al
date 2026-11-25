// Both codeunits belong to the same app.
codeunit 50172 "Original Calculation Api"
{
    // Published CalculateTotal(Amount: Decimal): Decimal was removed from here.
    // Existing callers still bind to this codeunit, not the replacement below.
}

codeunit 50173 "Replacement Calculation Api"
{
    // Same name and signature do not preserve the original codeunit's contract.
    procedure CalculateTotal(Amount: Decimal): Decimal
    begin
        exit(Amount * 1.2);
    end;
}
