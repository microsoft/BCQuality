report 50221 "Perf Sample AddLoadFields Bad"
{
    dataset
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            column(CustomerNo; "Customer No.") { }
            column(PostingDate; "Posting Date") { }
            column(Amount; Amount) { }

            trigger OnAfterGetRecord()
            begin
                // Source Code is not a dataset column, so its first access causes a
                // just-in-time load and updates the dataitem enumerator.
                RegisterSourceCode("Source Code");
            end;
        }
    }

    local procedure RegisterSourceCode(SourceCode: Code[10])
    begin
    end;
}
