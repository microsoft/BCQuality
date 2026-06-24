page 50356 "WS Read Only Good"
{
    PageType = API;
    Caption = 'customerLedgerEntry';
    APIPublisher = 'contoso';
    APIGroup = 'reporting';
    APIVersion = 'v1.0';
    EntityName = 'customerLedgerEntry';
    EntitySetName = 'customerLedgerEntries';
    ODataKeyFields = SystemId;
    SourceTable = "Cust. Ledger Entry";
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;

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
