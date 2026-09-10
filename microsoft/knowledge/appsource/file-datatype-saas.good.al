codeunit 50104 "Import File Reader"
{
    procedure ImportFile()
    var
        TempBlob: Codeunit "Temp Blob";
        InStream: InStream;
        FileName: Text;
    begin
        if UploadIntoStream('Import file', '', 'All Files (*.*)|*.*', FileName, InStream) then
            ParseStream(InStream);
    end;

    local procedure ParseStream(var InStream: InStream)
    begin
        // parse InStream content here
    end;
}
