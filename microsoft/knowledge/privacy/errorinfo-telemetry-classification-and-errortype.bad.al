codeunit 50308 "ErrorInfo Privacy Bad"
{
    procedure RaiseSynchronizationError(Customer: Record Customer; ResponseBody: Text)
    var
        FailureInfo: ErrorInfo;
    begin
        FailureInfo.Message := StrSubstNo('Synchronization failed for %1.', Customer."E-Mail");
        FailureInfo.DataClassification := DataClassification::SystemMetadata;
        FailureInfo.ErrorType := ErrorType::Internal;
        FailureInfo.DetailedMessage := ResponseBody;
        Error(FailureInfo);
    end;
}
