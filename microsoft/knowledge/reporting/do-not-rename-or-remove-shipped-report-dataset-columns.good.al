// Demonstration only. Shows the recommended pattern: released column names stay, and new data is added as new columns.
// Version 1.0 of this report shipped with columns No_, Name_, Balance_LCY and Phone_No.

report 50226 "Customer Balance Overview Good"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = BalanceExcel;

    dataset
    {
        dataitem(Customer; Customer)
        {
            column(No_; "No.") { }
            column(Name_; Name) { }
            column(Balance_LCY; "Balance (LCY)") { }
            // Kept for layouts outside this repository, although the shipped layout no longer shows it.
            column(Phone_No; "Phone No.") { }
            // New in version 2.0: added, not renamed.
            column(Credit_Limit_LCY; "Credit Limit (LCY)") { }
        }
    }

    rendering
    {
        layout(BalanceExcel)
        {
            Type = Excel;
            LayoutFile = './layouts/CustomerBalanceOverview.xlsx';
        }
    }
}
