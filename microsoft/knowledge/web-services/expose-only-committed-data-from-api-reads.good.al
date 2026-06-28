page 50348 "WS ReadCommitted Good"
{
    PageType = API;
    Caption = 'customer';
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

    trigger OnOpenPage()
    begin
        // Return only durably committed rows; ignore concurrent uncommitted writes.
        Rec.ReadIsolation := IsolationLevel::ReadCommitted;
    end;
}
