table 50100 "Sample Error Log Buffer"
{
    TableType = Temporary;
    fields
    {
        field(1; "Call Duration (ms)"; Integer) { }
        field(2; "Error Message"; Text[250]) { }
    }
}

codeunit 50100 "Sample Error Log Writer"
{
    // TableNo makes OnRun receive the Record that Session.StartSession
    // passes to the new session. This is the only data channel into that
    // session — there is no shared memory with the caller's instance.
    TableNo = "Sample Error Log Buffer";

    trigger OnRun()
    var
        ErrorLogEntry: Record "Sample Error Log";
    begin
        ErrorLogEntry.Init();
        ErrorLogEntry."Call Duration (ms)" := Rec."Call Duration (ms)";
        ErrorLogEntry."Error Message" :=
            CopyStr(Rec."Error Message", 1, MaxStrLen(ErrorLogEntry."Error Message"));
        ErrorLogEntry.Insert(true);
        Commit();
    end;
}

// Caller side: populate the buffer record, then hand it to StartSession.
// The insert-and-commit above happens inside the started session, so it
// survives even if the caller's own transaction rolls back afterward.
codeunit 50101 "Sample Error Log Caller Excerpt"
{
    procedure LogFailure(Duration: Integer; ErrorText: Text)
    var
        LogBuffer: Record "Sample Error Log Buffer" temporary;
        SessionId: Integer;
    begin
        LogBuffer."Call Duration (ms)" := Duration;
        LogBuffer."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(LogBuffer."Error Message"));
        Session.StartSession(SessionId, Codeunit::"Sample Error Log Writer", CompanyName, LogBuffer);
    end;
}
