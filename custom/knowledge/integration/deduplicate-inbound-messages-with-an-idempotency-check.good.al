// Best practice: deduplicate on the source system's stable id (External Reference + Type)
// BEFORE staging, backed by a unique key. A replay returns the prior result instead of
// being processed again. The internal Message ID is never the dedup key, because it is
// freshly generated per insert and so could never match a repeat.

table 50140 "Integration Message"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Message ID"; Guid) { Caption = 'Message ID'; }
        field(2; Direction; Enum "Integration Direction") { Caption = 'Direction'; }
        field(3; "Type"; Code[40]) { Caption = 'Type'; }
        field(4; Status; Enum "Integration Status") { Caption = 'Status'; }
        // The source-controlled stable id. This, not Message ID, is what dedup keys on.
        field(5; "External Reference"; Text[100]) { Caption = 'External Reference'; }
    }

    keys
    {
        key(PK; "Message ID") { Clustered = true; }
        // UNIQUE idempotency key: a second concurrent insert of the same delivery fails at
        // the database, so dedup holds even under a race, not only on the explicit lookup.
        key(Idempotency; "External Reference", "Type") { Unique = true; }
    }
}

codeunit 50141 "Inbound Dedup"
{
    procedure Stage(ExternalRef: Text[100]; MsgType: Code[40]; Payload: Text): Guid
    var
        Existing: Record "Integration Message";
        IntegrationMessage: Record "Integration Message";
    begin
        // The idempotency lookup: a single indexed read on the unique key.
        Existing.SetRange("External Reference", ExternalRef);
        Existing.SetRange(Type, MsgType);
        if Existing.FindFirst() then begin
            case Existing.Status of
                Existing.Status::Resolved:
                    // Already processed. Return the prior result; do NOT do the work again.
                    exit(Existing."Message ID");
                Existing.Status::"In Progress":
                    // A run is already handling this exact external reference. Reject the
                    // second one rather than process the same message concurrently.
                    Error('Message %1 of type %2 is already in progress', ExternalRef, MsgType);
            end;
            // Any other prior state (for example Failed): return the existing row so the
            // resolution flow handles it, instead of minting a duplicate.
            exit(Existing."Message ID");
        end;

        // No prior message exists: stage a genuinely new one.
        IntegrationMessage.Init();
        IntegrationMessage."Message ID" := CreateGuid(); // internal id, never the dedup key
        IntegrationMessage.Direction := IntegrationMessage.Direction::Inbound;
        IntegrationMessage."External Reference" := ExternalRef;
        IntegrationMessage.Type := MsgType;
        IntegrationMessage.Status := IntegrationMessage.Status::New;
        IntegrationMessage.SetRequest(Payload);
        // If a concurrent request slipped past the lookup, the unique key makes THIS Insert
        // fail rather than create a duplicate. Either way, the side effect runs at most once.
        IntegrationMessage.Insert(true);
        exit(IntegrationMessage."Message ID");
    end;
}
