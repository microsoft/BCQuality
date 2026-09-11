table 50112 "Queued Export Good"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; Payload; Text[250])
        {
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

}

codeunit 50112 "Queued Export Worker Good"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        QueuedExport: Record "Queued Export Good";
        Client: HttpClient;
        Content: HttpContent;
        ContentHeaders: HttpHeaders;
        JsonPayload: JsonObject;
        RequestBody: Text;
        Response: HttpResponseMessage;
    begin
        if not QueuedExport.FindFirst() then
            exit;

        JsonPayload.Add('idempotencyKey', Format(QueuedExport.SystemId));
        JsonPayload.Add('payload', QueuedExport.Payload);
        JsonPayload.WriteTo(RequestBody);

        Content.WriteFrom(RequestBody);
        Content.GetHeaders(ContentHeaders);
        ContentHeaders.Clear();
        ContentHeaders.Add('Content-Type', 'application/json');
        Client.Post('https://example.local/exports', Content, Response);
        if not Response.IsSuccessStatusCode() then
            Error('Export failed with HTTP status %1.', Response.HttpStatusCode());

        // The external service must atomically create a record only when idempotencyKey
        // does not exist. When the key already exists, it must return the existing record
        // without repeating the side effect.
        UpdateLocalStatus();
        QueuedExport.Delete();
    end;

    local procedure UpdateLocalStatus()
    begin
    end;
}