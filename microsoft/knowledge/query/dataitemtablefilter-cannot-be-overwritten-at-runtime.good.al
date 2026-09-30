query 50430 "Static Query Filter Good"
{
    QueryType = Normal;

    elements
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableFilter = "Document Type" = const(Order);

            column(DocumentNo; "No.")
            {
            }
            filter(StatusFilter; Status)
            {
            }
        }
    }
}

codeunit 50431 "Static Query Filter Good"
{
    procedure ReadReleasedOrders()
    var
        SalesHeader: Record "Sales Header";
        SalesHeaderQuery: Query "Static Query Filter Good";
    begin
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