// Swapped and miscased entity names: EntityName is plural and PascalCase while
// EntitySetName is singular. The single-record name reads as a collection and
// vice versa, and the leading capitals violate camelCase.
page 50343 "WS Entity Naming Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'Customers';
    EntitySetName = 'Customer';
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
