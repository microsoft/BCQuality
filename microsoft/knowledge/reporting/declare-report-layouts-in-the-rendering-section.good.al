// Demonstration only. Shows the recommended pattern: named layouts in the rendering section and a default chosen by name.

report 50224 "Orders By Salesperson Good"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultRenderingLayout = OpenOrdersWord;

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

    rendering
    {
        layout(OpenOrdersWord)
        {
            Type = Word;
            LayoutFile = './layouts/OpenOrdersBySalesperson.docx';
            Caption = 'Open orders (Word)';
            Summary = 'Printable list of open sales orders per salesperson.';
        }
        layout(OpenOrdersExcel)
        {
            Type = Excel;
            LayoutFile = './layouts/OpenOrdersBySalesperson.xlsx';
            Caption = 'Open orders (Excel)';
            Summary = 'Open sales orders for analysis in Excel.';
        }
    }
}
