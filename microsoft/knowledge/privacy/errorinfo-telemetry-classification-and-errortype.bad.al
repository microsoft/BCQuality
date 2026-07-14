codeunit 50308 "ErrorInfo Privacy Bad"
{
    procedure RaiseSynchronizationError(Customer: Record Customer)
    var
        FailureInfo: ErrorInfo;
    begin
        FailureInfo.Message := StrSubstNo('Synchronization failed for %1.', Customer."E-Mail");
        FailureInfo.DataClassification := DataClassification::SystemMetadata;
        FailureInfo.ErrorType := ErrorType::Internal;
        Error(FailureInfo);
    end;
}
