codeunit 50104 "Import File Reader"
{
    procedure ImportFile()
    var
        ImportFile: File;
        InStream: InStream;
    begin
        ImportFile.WriteMode(false);
        ImportFile.TextMode(true);
        ImportFile.Open('C:\Import\data.txt'); // fails in SaaS — no local filesystem
        ImportFile.CreateInStream(InStream);
    end;
}
