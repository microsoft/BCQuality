query 50434 "Column Query Filter Good"
{
    QueryType = Normal;

    elements
    {
        dataitem(SalesLine; "Sales Line")
        {
            DataItemTableFilter = Quantity = filter(> 0);

            column(DocumentNo; "Document No.")
            {
            }
            column(LineQuantity; Quantity)
            {
            }
        }
    }
}

codeunit 50435 "Column Query Filter Good"
{
    procedure ReadSmallPositiveLines()
    var
        SalesLineQuery: Query "Column Query Filter Good";
    begin
        // This combines with the invariant Quantity > 0 dataitem filter.
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