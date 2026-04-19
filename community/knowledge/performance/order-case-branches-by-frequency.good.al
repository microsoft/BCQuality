codeunit 50100 "Document Router"
{
    procedure Route(SalesHeader: Record "Sales Header")
    begin
        // In this deployment Orders are ~85% of posting calls, Invoices ~12%,
        // and the rest are edge cases. The hot branch goes first.
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                RouteOrder(SalesHeader);
            SalesHeader."Document Type"::Invoice:
                RouteInvoice(SalesHeader);
            SalesHeader."Document Type"::"Credit Memo":
                RouteCreditMemo(SalesHeader);
            SalesHeader."Document Type"::"Return Order":
                RouteReturnOrder(SalesHeader);
            else
                Error('Unexpected document type %1', SalesHeader."Document Type");
        end;
    end;

    local procedure RouteOrder(SalesHeader: Record "Sales Header") begin end;
    local procedure RouteInvoice(SalesHeader: Record "Sales Header") begin end;
    local procedure RouteCreditMemo(SalesHeader: Record "Sales Header") begin end;
    local procedure RouteReturnOrder(SalesHeader: Record "Sales Header") begin end;
}
