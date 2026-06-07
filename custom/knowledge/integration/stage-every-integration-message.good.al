// Best practice: a single staging table, a thin acceptance endpoint, and a
// background processor. The endpoint only validates and stages; it never posts
// and never calls the source system back. The Job Queue codeunit does the real
// work later, decoupled from the caller and from the remote system's uptime.

// --- The spine: one staging table for every inbound and outbound message ---
table 50100 "Integration Message"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Message ID"; Guid) { Caption = 'Message ID'; }
        field(2; Direction; Enum "Integration Direction") { Caption = 'Direction'; }
        // Type drives the dispatcher below. A new message kind is a new branch,
        // not a new published API page.
        field(3; "Type"; Code[40]) { Caption = 'Type'; }
        field(4; Status; Enum "Integration Status") { Caption = 'Status'; }
        // The source system's stable id. Drives inbound de-duplication, so it
        // carries a unique key, never the internal Message ID.
        field(5; "External Reference"; Text[100]) { Caption = 'External Reference'; }
        field(6; "Correlation ID"; Code[40]) { Caption = 'Correlation ID'; }
        field(10; Request; Blob) { Caption = 'Request'; }
        field(11; Response; Blob) { Caption = 'Response'; }
        field(20; "Error Message"; Text[2048]) { Caption = 'Error Message'; }
        field(21; "Retry Count"; Integer) { Caption = 'Retry Count'; }
    }

    keys
    {
        key(PK; "Message ID") { Clustered = true; }
        // The work key the Job Queue queries: which rows still need processing.
        key(Work; Status, Direction) { }
        // The idempotency key: detect a replayed inbound message at insert time.
        key(Idempotency; "External Reference", "Type") { }
    }
}

// --- Phase one: acceptance. Validate, stage, return. No posting here. ---
page 50100 "Integration Message API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'integration';
    APIVersion = 'v1.0';
    EntityName = 'integrationMessage';
    EntitySetName = 'integrationMessages';
    SourceTable = "Integration Message";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(externalReference; Rec."External Reference") { }
                field(type; Rec.Type) { }
                field(request; Rec.Request) { }
            }
        }
    }

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        // The only work the endpoint does: stamp identity and mark the row New.
        // Everything expensive happens later, in the Job Queue processor.
        Rec."Message ID" := CreateGuid();
        Rec.Direction := Rec.Direction::Inbound;
        Rec.Status := Rec.Status::New;
    end;
}

// --- Phase two: processing. Runs as a Job Queue entry, reads staged rows. ---
codeunit 50101 "Inbound Message Processor"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        IntegrationMessage: Record "Integration Message";
    begin
        // Read by Status, never from an HTTP call. The caller is long gone.
        IntegrationMessage.SetRange(Direction, IntegrationMessage.Direction::Inbound);
        IntegrationMessage.SetRange(Status, IntegrationMessage.Status::New);
        if IntegrationMessage.FindSet() then
            repeat
                Dispatch(IntegrationMessage);
            until IntegrationMessage.Next() = 0;
    end;

    // The Type field routes to the right handler. No giant CASE in the endpoint.
    local procedure Dispatch(var IntegrationMessage: Record "Integration Message")
    begin
        // ... resolve a handler by IntegrationMessage.Type and run it; on
        // success set Status::Resolved, on failure stamp Error Message and
        // bump Retry Count so the row stays auditable and re-runnable.
    end;
}
