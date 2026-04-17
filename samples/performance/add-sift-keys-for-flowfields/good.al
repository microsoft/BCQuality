tableextension 50118 "Perf Sample SIFTKey" extends "Cust. Ledger Entry"
{
    keys
    {
        key(PerfSampleOpenByCustomer; "Customer No.", Open, "Posting Date")
        {
            SumIndexFields = "Remaining Amt. (LCY)";
        }
    }
}
