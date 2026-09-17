query 50420 "Query Customer Sales Good"
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

codeunit 50421 "Query Filter Order Good"
{
    procedure ReadCustomer(CustomerNoFilter: Code[20])
    var
        CustomerSales: Query "Query Customer Sales Good";
    begin
        CustomerSales.SetRange(CustomerNo, CustomerNoFilter);
        CustomerSales.Open();
        while CustomerSales.Read() do
            ProcessCustomer(CustomerSales.CustomerNo);
        CustomerSales.Close();
    end;

    local procedure ProcessCustomer(CustomerNo: Code[20])
    begin
    end;
}
