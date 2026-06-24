// Unstable key: the endpoint addresses records by the business field "No.".
// When a user renames a customer's number, every external reference built on
// the old value dangles. ODataKeyFields should be SystemId instead.
page 50345 "WS SystemId Key Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'customer';
    EntitySetName = 'customers';
    ODataKeyFields = "No.";
    SourceTable = Customer;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(records)
            {
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
