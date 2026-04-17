report 50112 "Perf Sample AddLoadFields Good"
{
    dataset
    {
        dataitem(Cust; "Cust. Ledger Entry")
        {
            column(CustomerNo; "Customer No.") { }
            column(PostingDate; "Posting Date") { }
            column(Amount; Amount) { }

            trigger OnPreDataItem()
            begin
                AddLoadFields("Customer No.", "Posting Date", Amount);
            end;
        }
    }
}
