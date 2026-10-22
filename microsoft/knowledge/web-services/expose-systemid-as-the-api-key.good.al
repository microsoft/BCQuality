page 50344 "WS SystemId Key Good"
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
                field(number; Rec."No.")
                {
                    Caption = 'number';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName';
                }
            }
        }
    }
}
