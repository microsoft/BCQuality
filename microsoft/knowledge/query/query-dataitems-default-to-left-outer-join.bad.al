// Demonstration only. A sales-document count includes customers without any document.

query 50227 "Cust With Sales Docs Bad"
{
    QueryType = Normal;

    elements
    {
        dataitem(Customer; Customer)
        {
            column(CustomerNo; "No.") { }
            column(CustomerName; Name) { }
            // BAD: no child filter rejects nulls, so unmatched customers survive the default join.
            dataitem(SalesHeader; "Sales Header")
            {
                DataItemLink = "Sell-to Customer No." = Customer."No.";
                column(OrderNo; "No.") { }
            }
        }
    }
}

codeunit 50228 "Sales Doc Reminder Bad"
{
    procedure CountSalesDocsToRemind(): Integer
    var
        CustomersWithSalesDocs: Query "Cust With Sales Docs Bad";
        Total: Integer;
    begin
        CustomersWithSalesDocs.Open();
        while CustomersWithSalesDocs.Read() do
            Total += 1;
        CustomersWithSalesDocs.Close();
        exit(Total);
    end;
}
