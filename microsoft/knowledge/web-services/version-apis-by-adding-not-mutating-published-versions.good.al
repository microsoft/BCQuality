// Additive versioning: v2.0 carries the new shape while v1.0 stays published and
// unchanged. APIVersion accepts a list, so both contracts are served and
// existing clients keep working while new clients adopt v2.0.
page 50354 "WS API Versioning Good"
{
    PageType = API;
    Caption = 'customer';
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v2.0', 'v1.0';
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
