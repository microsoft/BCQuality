// Demonstration only. Shows the wrong pattern: a display column changes the grouping of a totals query.

query 50231 "Customer Sales Totals Bad"
{
    QueryType = Normal;

    elements
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            DataItemTableFilter = "Document Type" = const(Invoice);
            column(CustomerNo; "Customer No.") { }
            // BAD: Document No. varies within each customer, so the query now returns one row per
            // customer per invoice instead of one total per customer.
            column(DocumentNo; "Document No.") { }
            column(SalesLCY; "Sales (LCY)")
            {
                Method = Sum;
            }
        }
    }
}

codeunit 50232 "Customer Sales Lookup Bad"
{
    procedure GetSalesForCustomer(CustomerNo: Code[20]): Decimal
    var
        CustomerSalesTotals: Query "Customer Sales Totals Bad";
    begin
        CustomerSalesTotals.SetRange(CustomerNo, CustomerNo);
        CustomerSalesTotals.Open();
        // Reads only the first invoice's partial total.
        if CustomerSalesTotals.Read() then
            exit(CustomerSalesTotals.SalesLCY);
    end;
}
