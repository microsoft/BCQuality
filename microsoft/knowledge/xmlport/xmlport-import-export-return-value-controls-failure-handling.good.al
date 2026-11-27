codeunit 50360 "Sample Xmlport Import Good"
{
    procedure ImportItems(var SourceStream: InStream)
    begin
        // No return value: a failed import raises its own run-time error and stops the process.
        Xmlport.Import(Xmlport::"Sample Item Import", SourceStream);
    end;

    procedure ImportFile(var ImportLog: Record "Sample Import Log"; var SourceStream: InStream)
    begin
        // Return value used: every later step depends on it.
        if Xmlport.Import(Xmlport::"Sample Item Import", SourceStream) then
            ImportLog.Status := ImportLog.Status::Imported
        else
            ImportLog.Status := ImportLog.Status::Failed;
        ImportLog.Modify(true);
    end;
}
