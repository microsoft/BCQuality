codeunit 50307 "ErrorInfo Privacy Good"
{
    procedure RaiseSynchronizationError()
    var
        FailureInfo: ErrorInfo;
    begin
        FailureInfo.Message := SynchronizationFailedErr;
        FailureInfo.DataClassification := DataClassification::SystemMetadata;
        FailureInfo.ErrorType := ErrorType::Client;
        FailureInfo.DetailedMessage := RetryDiagnosticsTxt;
        Error(FailureInfo);
    end;

    var
        RetryDiagnosticsTxt: Label 'The remote service rejected the request. Review the integration telemetry event.';
        SynchronizationFailedErr: Label 'The synchronization could not be completed.';
}
