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

codeunit 50369 "Perf Summary Bad"
{
    procedure BuildSummary(CutoffDate: Date) RunId: Guid
    var
        Entry: Record "Perf Posted Entry";
        Scan: Record "Perf Posted Entry";
        Summary: Record "Perf Quantity Summary";
    begin
        RunId := CreateGuid();
        Entry.SetFilter("Posting Date", '..%1', CutoffDate);
        if Entry.FindSet() then
            repeat
                Scan.SetRange("Item No.", Entry."Item No.");
                Scan.SetRange("Location Code", Entry."Location Code");
                Scan.SetFilter("Posting Date", '..%1', CutoffDate);
                Scan.CalcSums(Quantity);

                if Summary.Get(RunId, Entry."Item No.", Entry."Location Code") then begin
                    Summary.Quantity := Scan.Quantity;
                    Summary.Modify(false);
                end else begin
                    Summary.Init();
                    Summary."Run ID" := RunId;
                    Summary."Item No." := Entry."Item No.";
                    Summary."Location Code" := Entry."Location Code";
                    Summary.Quantity := Scan.Quantity;
                    Summary.Insert(false);
                end;
            until Entry.Next() = 0;
    end;
}
