// Each invocation exclusively owns a new run; these tables have no write logic.
table 50364 "Perf Input"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Row No."; Integer) { }
        field(2; "Item No."; Code[20]) { }
        field(3; Quantity; Decimal) { }
    }

    keys
    {
        key(PK; "Row No.") { Clustered = true; }
    }
}

table 50365 "Perf Output"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Run ID"; Guid) { }
        field(2; "Line No."; Integer) { }
        field(3; "Item No."; Code[20]) { }
        field(4; Quantity; Decimal) { }
    }

    keys
    {
        key(PK; "Run ID", "Line No.") { Clustered = true; }
    }
}

codeunit 50366 "Perf Buffered Insert Bad"
{
    procedure CopyRun(var TempInput: Record "Perf Input" temporary) RunId: Guid
    var
        Output: Record "Perf Output";
        NextLineNo: Integer;
    begin
        RunId := CreateGuid();
        Output.SetRange("Run ID", RunId);
        if TempInput.FindSet() then
            repeat
                if Output.FindLast() then
                    NextLineNo := Output."Line No." + 1
                else
                    NextLineNo := 1;
                Output.Init();
                Output."Run ID" := RunId;
                Output."Line No." := NextLineNo;
                Output."Item No." := TempInput."Item No.";
                Output.Insert(false);
                Output.Quantity := TempInput.Quantity;
                Output.Modify(false);
            until TempInput.Next() = 0;
    end;
}
