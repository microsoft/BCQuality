report 50220 "Perf Sample AddLoadFields Good"
{
    dataset
    {
        dataitem(CustLedgerEntry; "Cust. Ledger Entry")
        {
            column(CustomerNo; "Customer No.") { }
            column(PostingDate; "Posting Date") { }
            column(Amount; Amount) { }

            trigger OnPreDataItem()
            begin
                // Dataset columns are selected by the report compiler. Source Code is
                // extra because only trigger code reads it.
                CustLedgerEntry.AddLoadFields("Source Code");
            end;

            trigger OnAfterGetRecord()
            begin
                RegisterSourceCode("Source Code");
            end;
        }
    }

    local procedure RegisterSourceCode(SourceCode: Code[10])
    begin
    end;
}
