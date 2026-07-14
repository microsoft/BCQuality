codeunit 50307 "ErrorInfo Privacy Good"
{
    procedure RaiseSynchronizationError()
    var
        FailureInfo: ErrorInfo;
    begin
        FailureInfo.Message := SynchronizationFailedErr;
        FailureInfo.DataClassification := DataClassification::SystemMetadata;
        FailureInfo.ErrorType := ErrorType::Client;
        Error(FailureInfo);
    end;

    var
        SynchronizationFailedErr: Label 'The synchronization could not be completed.';
}
