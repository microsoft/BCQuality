query 50432 "Column Query Filter Bad"
{
    QueryType = Normal;

    elements
    {
        dataitem(SalesLine; "Sales Line")
        {
            column(DocumentNo; "Document No.")
            {
            }
            column(LineQuantity; Quantity)
            {
                ColumnFilter = LineQuantity = filter(> 0);
            }
        }
    }
}

codeunit 50433 "Column Query Filter Bad"
{
    procedure ReadSmallPositiveLines()
    var
        SalesLineQuery: Query "Column Query Filter Bad";
    begin
        // This replaces > 0, so negative quantities are also returned.
        SalesLineQuery.SetFilter(LineQuantity, '<100');
        SalesLineQuery.Open();
        while SalesLineQuery.Read() do
            ProcessLine(SalesLineQuery.DocumentNo, SalesLineQuery.LineQuantity);
        SalesLineQuery.Close();
    end;

    local procedure ProcessLine(DocumentNo: Code[20]; Quantity: Decimal)
    begin
    end;
}