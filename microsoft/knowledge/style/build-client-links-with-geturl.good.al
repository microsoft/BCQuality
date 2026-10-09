codeunit 50620 "Sales Order Link"
{
    procedure GetSalesOrderLink(SalesHeader: Record "Sales Header"): Text
    begin
        exit(GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"Sales Order", SalesHeader));
    end;
}
