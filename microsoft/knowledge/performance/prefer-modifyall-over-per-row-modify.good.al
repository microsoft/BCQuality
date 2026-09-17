table 50242 "Perf Import Staging Entry"
{
    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; "Batch ID"; Guid) { }
        field(3; Processed; Boolean) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}

codeunit 50242 "Perf Sample ModifyAll Good"
{
    procedure MarkBatchProcessed(BatchId: Guid)
    var
        StagingEntry: Record "Perf Import Staging Entry";
    begin
        StagingEntry.SetRange("Batch ID", BatchId);
        // Processed has no OnValidate logic, and the equivalent loop uses Modify(false).
        StagingEntry.ModifyAll(Processed, true, false);
    end;
}
