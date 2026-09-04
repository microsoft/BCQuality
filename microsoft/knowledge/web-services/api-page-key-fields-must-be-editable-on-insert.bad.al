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
                field(customerNo; Rec."No.")
                {
                    Editable = false; // consumer must supply "No." on POST — this rejects it
                }
                field(name; Rec.Name) { }
            }
        }
    }
}
