table 50112 "Queued Export Bad"
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

codeunit 50112 "Queued Export Worker Bad"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        QueuedExport: Record "Queued Export Bad";
        Client: HttpClient;
        Content: HttpContent;
        Response: HttpResponseMessage;
    begin
        if not QueuedExport.FindFirst() then
            exit;

        Content.WriteFrom(QueuedExport.Payload);
        Client.Post('https://example.local/exports', Content, Response);
        if not Response.IsSuccessStatusCode() then
            Error('Export failed with HTTP status %1.', Response.HttpStatusCode());

        // If this local step fails, the external export exists but this row is retried.
        UpdateLocalStatus();
        FinalizeExport(QueuedExport);
    end;

    local procedure UpdateLocalStatus()
    begin
    end;

    local procedure FinalizeExport(var QueuedExport: Record "Queued Export Bad")
    begin
        QueuedExport.Delete();
    end;
}