// Input stays stable for this run; output contains one row per group with entries.
table 50367 "Perf Posted Entry"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Item No."; Code[20]) { }
        field(3; "Location Code"; Code[10]) { }
        field(4; "Posting Date"; Date) { }
        field(5; Quantity; Decimal) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(ByItemLocationDate; "Item No.", "Location Code", "Posting Date")
        {
            SumIndexFields = Quantity;
        }
    }
}

table 50368 "Perf Quantity Summary"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Run ID"; Guid) { }
        field(2; "Item No."; Code[20]) { }
        field(3; "Location Code"; Code[10]) { }
        field(4; Quantity; Decimal) { }
    }

    keys
    {
        key(PK; "Run ID", "Item No.", "Location Code") { Clustered = true; }
    }
}

query 50370 "Perf Grouped Quantity"
{
    QueryType = Normal;

    elements
    {
        dataitem(Entry; "Perf Posted Entry")
        {
            column(ItemNo; "Item No.") { }
            column(LocationCode; "Location Code") { }
            column(TotalQuantity; Quantity)
            {
                Method = Sum;
            }
            filter(PostingDate; "Posting Date") { }
        }
    }
}

codeunit 50369 "Perf Summary Good"
{
    procedure BuildSummary(CutoffDate: Date) RunId: Guid
    var
        Totals: Query "Perf Grouped Quantity";
        TempSummary: Record "Perf Quantity Summary" temporary;
        Summary: Record "Perf Quantity Summary";
    begin
        RunId := CreateGuid();
        Totals.SetFilter(PostingDate, '..%1', CutoffDate);
        Totals.Open();
        while Totals.Read() do begin
            TempSummary.Init();
            TempSummary."Run ID" := RunId;
            TempSummary."Item No." := Totals.ItemNo;
            TempSummary."Location Code" := Totals.LocationCode;
            TempSummary.Quantity := Totals.TotalQuantity;
            TempSummary.Insert();
        end;
        Totals.Close();

        if TempSummary.FindSet() then
            repeat
                Summary.Init();
                Summary."Run ID" := RunId;
                Summary."Item No." := TempSummary."Item No.";
                Summary."Location Code" := TempSummary."Location Code";
                Summary.Quantity := TempSummary.Quantity;
                Summary.Insert(false);
            until TempSummary.Next() = 0;
    end;
}
