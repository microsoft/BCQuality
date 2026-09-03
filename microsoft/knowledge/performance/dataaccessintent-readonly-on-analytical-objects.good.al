report 50100 "Cust List ReadOnly Good"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(Customer; Customer)
        {
            column(No; "No.") { }
            column(Name; Name) { }
        }
    }
}
