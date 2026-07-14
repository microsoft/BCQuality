table 50100 "Perf Import Buffer"
{
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Batch ID"; Guid) { }
        field(3; Payload; Blob) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(ByBatch; "Batch ID") { }
    }
}

codeunit 50100 "Perf Import Buffer Cleanup"
{
    procedure ClearBatch(BatchId: Guid)
    var
        ImportBuffer: Record "Perf Import Buffer";
    begin
        ImportBuffer.SetRange("Batch ID", BatchId);
        if ImportBuffer.FindSet() then
            repeat
                ImportBuffer.Delete(false);
            until ImportBuffer.Next() = 0;
    end;
}
