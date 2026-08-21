report 50100 "Cust List ReadOnly Bad"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    // Missing DataAccessIntent = ReadOnly; the scan hits the primary replica.

    dataset
    {
        dataitem(Customer; Customer)
        {
            column(No; "No.") { }
            column(Name; Name) { }
        }
    }
}
