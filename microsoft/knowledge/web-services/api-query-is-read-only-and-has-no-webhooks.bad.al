page 50351 "Sample Customer Sales API Bad"
{
    PageType = API;
    APIPublisher = 'contoso';
    APIGroup = 'sales';
    APIVersion = 'v1.0';
    EntityName = 'customerSale';
    EntitySetName = 'customerSales';
    SourceTable = Customer;
    ODataKeyFields = SystemId;
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId) { }
                field(customerNumber; Rec."No.") { }
                field(customerName; Rec.Name) { }
                field(totalSalesAmount; TotalSalesAmount) { }
            }
        }
    }

    // A read-only sales total exposed as a writable page: the aggregate is
    // computed per row in a trigger instead of by one aggregated query.
    trigger OnAfterGetRecord()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Customer No.", Rec."No.");
        CustLedgerEntry.CalcSums("Sales (LCY)");
        TotalSalesAmount := CustLedgerEntry."Sales (LCY)";
    end;

    var
        TotalSalesAmount: Decimal;
}
