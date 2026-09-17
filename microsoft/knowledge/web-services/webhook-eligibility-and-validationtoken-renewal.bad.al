query 50355 "WS Webhook Customer Query"
{
    QueryType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'webhookCustomer';
    EntitySetName = 'webhookCustomers';

    elements
    {
        dataitem(customer; Customer)
        {
            column(id; SystemId)
            {
            }
            column(displayName; Name)
            {
            }
        }
    }
}
