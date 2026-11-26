query 50350 "Sample Customer Sales API Good"
{
    QueryType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'customerSale';
    EntitySetName = 'customerSales';

    elements
    {
        dataitem(Customer; Customer)
        {
            column(customerId; SystemId) { }
            column(customerNumber; "No.") { }
            column(customerName; Name) { }

            dataitem(CustLedgerEntry; "Cust. Ledger Entry")
            {
                DataItemLink = "Customer No." = Customer."No.";
                SqlJoinType = InnerJoin;

                // One read-only request returns the joined, aggregated rows.
                column(totalSalesAmount; "Sales (LCY)")
                {
                    Method = Sum;
                }
            }
        }
    }
}
