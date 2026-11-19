codeunit 50361 "Sample Xmlport Import Bad"
{
    procedure ImportFile(var ImportLog: Record "Sample Import Log"; var SourceStream: InStream)
    var
        Imported: Boolean;
    begin
        // The return value suppresses the run-time error, and nothing acts on it.
        Imported := Xmlport.Import(Xmlport::"Sample Item Import", SourceStream);

        // A file that was not imported is recorded as done.
        ImportLog.Status := ImportLog.Status::Imported;
        ImportLog.Modify(true);
    end;
}
