codeunit 50101 "Sample Web Service Caller"
{
    procedure CallExternalService()
    var
        ErrorLogEntry: Record "Sample Error Log";
    begin
        // BUG: the log write happens inside the same transaction as the
        // risky call, using the same Record instance as the caller.
        if not TryCallService() then begin
            ErrorLogEntry.Init();
            ErrorLogEntry."Error Message" := CopyStr(GetLastErrorText(), 1, 250);
            ErrorLogEntry.Insert();
            Error(GetLastErrorText());
            // Error() above rolls back this transaction - including the
            // Insert() just made. The failure is never actually logged.
        end;
    end;

    [TryFunction]
    local procedure TryCallService()
    begin
        // ... external call that may fail ...
    end;
}
