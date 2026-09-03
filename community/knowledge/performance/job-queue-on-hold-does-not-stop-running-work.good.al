table 50114 "Job Cancellation Control"
{
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Job Queue Entry ID"; Guid)
        {
        }
        field(2; "Stop Requested"; Boolean)
        {
        }
    }

    keys
    {
        key(PK; "Job Queue Entry ID")
        {
            Clustered = true;
        }
    }
}

codeunit 50114 "Job Queue On Hold Good"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        repeat
            if not ProcessNextBatch() then
                exit;
        until IsStopRequested(Rec.ID);
    end;

    local procedure IsStopRequested(JobQueueEntryId: Guid): Boolean
    var
        JobCancellationControl: Record "Job Cancellation Control";
    begin
        if not JobCancellationControl.Get(JobQueueEntryId) then
            exit(false);

        exit(JobCancellationControl."Stop Requested");
    end;

    local procedure ProcessNextBatch(): Boolean
    begin
        exit(false);
    end;
}