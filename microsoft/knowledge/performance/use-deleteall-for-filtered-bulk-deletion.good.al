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
        // This staging table has no base delete trigger. Installed extensions and
        // subscribers must also be checked before assuming the set-based fast path.
        ImportBuffer.DeleteAll(false);
    end;
}
