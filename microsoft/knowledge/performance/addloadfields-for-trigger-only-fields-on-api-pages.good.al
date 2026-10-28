page 50230 "Perf Sample API LoadFields Good"
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

    trigger OnOpenPage()
    begin
        // Bound fields are selected by the platform. Post Code and City are extra
        // because only OnAfterGetRecord reads them.
        Rec.AddLoadFields("Post Code", City);
    end;

    trigger OnAfterGetRecord()
    begin
        AddressText := Rec."Post Code" + ' ' + Rec.City;
    end;

    var
        AddressText: Text;
}
