report 50107 "Selected Sales Orders"
{
    ProcessingOnly = true;

    dataset
    {
        dataitem(SalesHeader; "Sales Header")
        {
            DataItemTableView = where("Document Type" = const(Order), Status = const(Open));
        }
    }
}

codeunit 50108 "Run Selected Sales Orders"
{
    procedure RunReleasedOrders()
    var
        SalesHeader: Record "Sales Header";
        SelectedSalesOrders: Report "Selected Sales Orders";
    begin
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SetRange(Status, SalesHeader.Status::Released);
        SelectedSalesOrders.SetTableView(SalesHeader);
        SelectedSalesOrders.RunModal();
    end;
}