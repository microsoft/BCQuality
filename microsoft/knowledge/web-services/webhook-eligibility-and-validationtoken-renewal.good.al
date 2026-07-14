page 50354 "WS Webhook Customer API"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'webhookCustomer';
    EntitySetName = 'webhookCustomers';
    ODataKeyFields = SystemId;
    SourceTable = Customer;

    layout
    {
        area(content)
        {
            repeater(records)
            {
                field(id; Rec.SystemId)
                {
                    Editable = false;
                }
                field(displayName; Rec.Name)
                {
                }
            }
        }
    }
}
