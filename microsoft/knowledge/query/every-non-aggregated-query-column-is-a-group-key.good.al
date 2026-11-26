// Demonstration only. Shows the recommended pattern: only the grouping column is a non-aggregated column.

query 50233 "Customer Sales Totals Good"
{
    QueryType = Normal;

    elements
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            DataItemTableFilter = "Document Type" = const(Invoice);
            column(CustomerNo; "Customer No.") { }
            column(SalesLCY; "Sales (LCY)")
            {
                Method = Sum;
            }
        }
    }
}

codeunit 50234 "Customer Sales Lookup Good"
{
    procedure GetSalesForCustomer(CustomerNo: Code[20]): Decimal
    var
        CustomerSalesTotals: Query "Customer Sales Totals Good";
    begin
        CustomerSalesTotals.SetRange(CustomerNo, CustomerNo);
        CustomerSalesTotals.Open();
        if CustomerSalesTotals.Read() then
            exit(CustomerSalesTotals.SalesLCY);
    end;
}
