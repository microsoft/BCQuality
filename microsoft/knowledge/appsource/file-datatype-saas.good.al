codeunit 50104 "Import File Reader"
{
    procedure ImportFile()
    var
        TempBlob: Codeunit "Temp Blob";
        FromInStream: InStream;
        ToOutStream: OutStream;
        InStream: InStream;
    begin
        if not UploadIntoStream('All Files (*.*)|*.*', FromInStream) then
            exit;

        TempBlob.CreateOutStream(ToOutStream);
        CopyStream(ToOutStream, FromInStream);

        TempBlob.CreateInStream(InStream);
        ParseStream(InStream);
    end;

    local procedure ParseStream(var InStream: InStream)
    begin
        // parse InStream content here
    end;
}
