// The original page remains the unchanged v1.0 contract.
page 50354 "Customer API v1"
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

// A separate object carries the changed v2.0 shape.
page 50356 "Customer API v2"
{
    PageType = API;
    Caption = 'customer';
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v2.0';
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
                field(legalName; Rec.Name)
                {
                    Caption = 'legalName';
                }
            }
        }
    }
}
