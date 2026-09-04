page 50101 "Customer Info API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'customerInfo';
    EntitySetName = 'customerInfos';
    SourceTable = Customer;
    ODataKeyFields = "No.";
    InsertAllowed = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(customerNo; Rec."No.") { }
                field(name; Rec.Name) { }
            }
        }
    }
}
