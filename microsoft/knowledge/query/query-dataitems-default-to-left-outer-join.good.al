// Demonstration only. InnerJoin excludes unmatched rows; a null-rejecting child filter is also valid.

query 50229 "Cust With Sales Docs Good"
{
    QueryType = Normal;

    elements
    {
        dataitem(Customer; Customer)
        {
            column(CustomerNo; "No.") { }
            column(CustomerName; Name) { }
            dataitem(SalesHeader; "Sales Header")
            {
                DataItemLink = "Sell-to Customer No." = Customer."No.";
                SqlJoinType = InnerJoin;
                column(OrderNo; "No.") { }
            }
        }
    }
}

codeunit 50230 "Sales Doc Reminder Good"
{
    procedure CountSalesDocsToRemind(): Integer
    var
        CustomersWithSalesDocs: Query "Cust With Sales Docs Good";
        Total: Integer;
    begin
        CustomersWithSalesDocs.Open();
        while CustomersWithSalesDocs.Read() do
            Total += 1;
        CustomersWithSalesDocs.Close();
        exit(Total);
    end;

    procedure CountOpenOrdersToRemind(): Integer
    var
        CustomersWithOpenOrders: Query "Cust With Open Orders";
        Total: Integer;
    begin
        CustomersWithOpenOrders.Open();
        while CustomersWithOpenOrders.Read() do
            Total += 1;
        CustomersWithOpenOrders.Close();
        exit(Total);
    end;
}

query 50235 "Cust With Open Orders"
{
    QueryType = Normal;

    elements
    {
        dataitem(Customer; Customer)
        {
            column(CustomerNo; "No.") { }
            column(CustomerName; Name) { }
            dataitem(SalesHeader; "Sales Header")
            {
                DataItemLink = "Sell-to Customer No." = Customer."No.";
                DataItemTableFilter = "Document Type" = const(Order), Status = const(Open);
                column(OrderNo; "No.") { }
            }
        }
    }
}
