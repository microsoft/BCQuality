// APIVersion is omitted. This is valid, but the endpoint defaults to beta
// instead of publishing the intended explicit stable contract.
page 50341 "WS Required Props Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    EntityName = 'customer';
    EntitySetName = 'customers';
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            repeater(records)
            {
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName';
                }
            }
        }
    }
}
