query 50422 "Query Customer Sales Bad"
{
    QueryType = Normal;

    elements
    {
        dataitem(Customer; Customer)
        {
            column(CustomerNo; "No.") { }
            column(CustomerName; Name) { }
        }
    }
}

codeunit 50423 "Query Filter Order Bad"
{
    procedure ReadCustomer(CustomerNoFilter: Code[20])
    var
        CustomerSales: Query "Query Customer Sales Bad";
    begin
        CustomerSales.Open();
        CustomerSales.SetRange(CustomerNo, CustomerNoFilter);
        while CustomerSales.Read() do
            ProcessCustomer(CustomerSales.CustomerNo);
    end;

    local procedure ProcessCustomer(CustomerNo: Code[20])
    begin
    end;
}
