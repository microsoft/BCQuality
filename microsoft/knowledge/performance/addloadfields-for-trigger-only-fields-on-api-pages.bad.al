page 50231 "Perf Sample API LoadFields Bad"
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

    layout
    {
        area(Content)
        {
            repeater(Records)
            {
                field(id; Rec.SystemId) { }
                field(number; Rec."No.") { }
                field(displayName; Rec.Name) { }
                field(address; AddressText) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        // Post Code and City are not bound to any control, so the platform does not
        // load them. Reading them here causes a just-in-time load for every row.
        AddressText := Rec."Post Code" + ' ' + Rec.City;
    end;

    var
        AddressText: Text;
}
