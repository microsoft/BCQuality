codeunit 50190 "Error Type Good Sample"
{
    procedure ApplyLedgerBucket(BucketId: Integer)
    var
        InternalErr: ErrorInfo;
    begin
        if not BucketInitialized(BucketId) then begin
            InternalErr.ErrorType := ErrorType::Internal;
            InternalErr.Message := StrSubstNo('Ledger bucket %1 was not initialized before posting.', BucketId);
            InternalErr.DetailedMessage := 'Internal invariant violated. Inspect the call stack captured in telemetry.';
            Error(InternalErr);
        end;
    end;

    local procedure BucketInitialized(BucketId: Integer): Boolean
    begin
        exit(false);
    end;
}
