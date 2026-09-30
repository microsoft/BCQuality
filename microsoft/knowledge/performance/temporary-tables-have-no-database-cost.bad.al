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

codeunit 50374 "Perf Temp Totals Bad"
{
    procedure SumDisplayedItemTotals(var TempCells: Record "Perf Cell" temporary) DisplayedTotal: Decimal
    var
        TempScan: Record "Perf Cell" temporary;
        ItemTotal: Decimal;
    begin
        TempScan.Copy(TempCells, true);
        if TempCells.FindSet() then
            repeat
                TempScan.Reset();
                TempScan.SetRange("Item No.", TempCells."Item No.");
                ItemTotal := 0;
                if TempScan.FindSet() then
                    repeat
                        ItemTotal += TempScan.Quantity;
                    until TempScan.Next() = 0;
                DisplayedTotal += ItemTotal;
            until TempCells.Next() = 0;
    end;
}
