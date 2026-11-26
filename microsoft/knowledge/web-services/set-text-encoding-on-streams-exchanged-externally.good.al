// Demonstration only. UTF-8 text is downloaded byte-for-byte through a default-encoding InStream.

codeunit 50191 "Customer CSV Export Good"
{
    procedure ExportCustomers()
    var
        Customer: Record Customer;
        ExportBuffer: Record "Export Buffer Demo" temporary;
        CsvOutStream: OutStream;
        CsvInStream: InStream;
        FileName: Text;
    begin
        ExportBuffer.Content.CreateOutStream(CsvOutStream, TextEncoding::UTF8);
        if Customer.FindSet() then
            repeat
                CsvOutStream.WriteText(Customer."No." + ';' + Customer.Name);
                CsvOutStream.WriteText();
            until Customer.Next() = 0;

        ExportBuffer.Content.CreateInStream(CsvInStream);
        FileName := 'customers.csv';
        DownloadFromStream(CsvInStream, '', '', '', FileName);
    end;
}

table 50191 "Export Buffer Demo"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; Content; Blob) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
