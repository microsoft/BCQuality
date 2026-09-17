table 50243 "Perf Import Staging Entry"
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

codeunit 50243 "Perf Sample ModifyAll Bad"
{
    procedure MarkBatchProcessed(BatchId: Guid)
    var
        StagingEntry: Record "Perf Import Staging Entry";
    begin
        StagingEntry.SetRange("Batch ID", BatchId);
        if StagingEntry.FindSet(true) then
            repeat
                StagingEntry.Processed := true;
                StagingEntry.Modify(false);
            until StagingEntry.Next() = 0;
    end;
}
