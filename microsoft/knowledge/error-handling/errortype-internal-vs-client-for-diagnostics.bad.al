codeunit 50191 "Error Type Bad Sample"
{
    procedure ApplyLedgerBucket(BucketId: Integer)
    begin
        // Developer-facing detail shown straight to the user, and no structured telemetry signal.
        if not BucketInitialized(BucketId) then
            Error('Unexpected state: ledger bucket %1 not initialized', BucketId);
    end;

    local procedure BucketInitialized(BucketId: Integer): Boolean
    begin
        exit(false);
    end;
}
