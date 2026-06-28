// Breaking change in place: the published v1.0 is edited rather than versioned.
// EntityName was renamed from 'customer' to 'client' and the displayName field
// was removed, so the single declared version now serves a different contract
// than the one clients integrated against. Every existing consumer breaks.
page 50355 "WS API Versioning Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'client';
    EntitySetName = 'clients';
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
            }
        }
    }
}
