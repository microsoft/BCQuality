// Caller supplies an unfiltered temporary buffer that does not change during this call.
table 50373 "Perf Cell"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Cell No."; Integer) { }
        field(2; "Item No."; Code[20]) { }
        field(3; Quantity; Decimal) { }
    }

    keys
    {
        key(PK; "Cell No.") { Clustered = true; }
    }
}

codeunit 50374 "Perf Temp Totals Good"
{
    procedure SumDisplayedItemTotals(var TempCells: Record "Perf Cell" temporary) DisplayedTotal: Decimal
    var
        TotalsByItem: Dictionary of [Code[20], Decimal];
        ItemTotal: Decimal;
    begin
        if TempCells.FindSet() then
            repeat
                if TotalsByItem.Get(TempCells."Item No.", ItemTotal) then
                    TotalsByItem.Set(TempCells."Item No.", ItemTotal + TempCells.Quantity)
                else
                    TotalsByItem.Add(TempCells."Item No.", TempCells.Quantity);
            until TempCells.Next() = 0;

        if TempCells.FindSet() then
            repeat
                DisplayedTotal += TotalsByItem.Get(TempCells."Item No.");
            until TempCells.Next() = 0;
    end;
}
