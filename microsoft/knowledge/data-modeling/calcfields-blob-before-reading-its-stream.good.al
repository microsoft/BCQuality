// Demonstration only. Shows the recommended pattern: the BLOB field is calculated before its stream is read.

codeunit 50189 "Payload Reader Good"
{
    procedure GetPayload(EntryNo: Integer): Text
    var
        IntegrationLog: Record "Integration Log Demo";
        PayloadInStream: InStream;
        PayloadText: Text;
    begin
        IntegrationLog.Get(EntryNo);
        IntegrationLog.CalcFields(Payload);
        IntegrationLog.Payload.CreateInStream(PayloadInStream, TextEncoding::UTF8);
        PayloadInStream.ReadText(PayloadText);
        exit(PayloadText);
    end;
}

table 50189 "Integration Log Demo"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer) { }
        field(2; Payload; Blob) { }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
