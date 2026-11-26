// Demonstration only. Shows the wrong pattern: a new report declares its layouts with the legacy properties.

report 50223 "Orders By Salesperson Bad"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    // BAD: legacy, type-based layout properties on a new report.
    DefaultLayout = Word;
    WordLayout = './layouts/OpenOrdersBySalesperson.docx';
    ExcelLayout = './layouts/OpenOrdersBySalesperson.xlsx';

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = where("Document Type" = const(Order));
            column(No; "No.") { }
            column(SalespersonCode; "Salesperson Code") { }
            column(Amount; Amount) { }
        }
    }
}
