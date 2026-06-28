// Committed-only contract, but no isolation level is set. Reads run at the
// default and can observe in-flight, uncommitted writes from concurrent
// transactions. A consumer may fetch a row that is later rolled back — a dirty
// read of data that never durably existed.
page 50349 "WS ReadCommitted Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customers';
    ODataKeyFields = SystemId;
    SourceTable = Customer;
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
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName';
                }
            }
        }
    }
}
