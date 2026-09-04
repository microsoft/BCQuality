codeunit 50100 "Sample Error Log Writer"
{
    // Started via Session.StartSession so its commit is independent of the
    // caller's transaction. Does one thing: insert the log entry, commit.
    trigger OnRun()
    var
        ErrorLogEntry: Record "Sample Error Log";
    begin
        ErrorLogEntry.Init();
        ErrorLogEntry."Call Duration (ms)" := CallDurationMs;
        ErrorLogEntry."Error Message" :=
            CopyStr(ErrorMessageText, 1, MaxStrLen(ErrorLogEntry."Error Message"));
        ErrorLogEntry.Insert(true);
        Commit();
    end;

    procedure SetParameters(Duration: Integer; ErrorText: Text)
    begin
        CallDurationMs := Duration;
        ErrorMessageText := ErrorText;
    end;

    var
        CallDurationMs: Integer;
        ErrorMessageText: Text;
}
