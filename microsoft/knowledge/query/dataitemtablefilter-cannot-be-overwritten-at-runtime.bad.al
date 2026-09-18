query 50428 "Static Query Filter Bad"
{
    QueryType = Normal;

    elements
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableFilter = Status = const(Open);

            column(DocumentNo; "No.")
            {
            }
            filter(StatusFilter; Status)
            {
            }
        }
    }
}

codeunit 50429 "Static Query Filter Bad"
{
    procedure ReadReleasedOrders()
    var
        SalesHeader: Record "Sales Header";
        SalesHeaderQuery: Query "Static Query Filter Bad";
    begin
        // This is combined with Status = Open and returns no rows.
        SalesHeaderQuery.SetRange(StatusFilter, SalesHeader.Status::Released);
        SalesHeaderQuery.Open();
        while SalesHeaderQuery.Read() do
            ProcessOrder(SalesHeaderQuery.DocumentNo);
        SalesHeaderQuery.Close();
    end;

    local procedure ProcessOrder(DocumentNo: Code[20])
    begin
    end;
}