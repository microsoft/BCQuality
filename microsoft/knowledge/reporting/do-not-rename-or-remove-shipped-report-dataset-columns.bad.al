// Demonstration only. Shows the wrong pattern: a released report's dataset columns are renamed and removed.
// Version 1.0 of this report shipped with columns No_, Name_, Balance_LCY and Phone_No.

report 50225 "Customer Balance Overview Bad"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = BalanceExcel;

    dataset
    {
        dataitem(Customer; Customer)
        {
            // BAD: renamed from No_, Name_ and Balance_LCY for naming style. User-defined Excel and Word
            // layouts created from version 1.0 still bind to the old names.
            column(CustomerNo; "No.") { }
            column(CustomerName; Name) { }
            column(BalanceLCY; "Balance (LCY)") { }
            // BAD: Phone_No was removed because the layout in this repository no longer uses it.
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
