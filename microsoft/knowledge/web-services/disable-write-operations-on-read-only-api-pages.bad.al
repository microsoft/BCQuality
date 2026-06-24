// Intended for read-only consumption, but the CRUD guards are omitted. With
// InsertAllowed/ModifyAllowed/DeleteAllowed left at their writable defaults the
// endpoint silently accepts POST, PATCH, and DELETE, so a client can mutate or
// remove ledger data this API was never meant to expose for writing.
page 50357 "WS Read Only Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'reporting';
    APIVersion = 'v1.0';
    EntityName = 'customerLedgerEntry';
    EntitySetName = 'customerLedgerEntries';
    ODataKeyFields = SystemId;
    SourceTable = "Cust. Ledger Entry";

    layout
    {
        area(content)
        {
            repeater(records)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id';
                    Editable = false;
                }
                field(entryNumber; Rec."Entry No.")
                {
                    Caption = 'entryNumber';
                }
                field(postingDate; Rec."Posting Date")
                {
                    Caption = 'postingDate';
                }
            }
        }
    }
}
