page 50342 "WS Entity Naming Good"
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
    DelayedInsert = true;

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
