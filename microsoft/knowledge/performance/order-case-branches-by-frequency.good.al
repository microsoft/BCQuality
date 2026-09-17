codeunit 50100 "Document Router"
{
    procedure Route(SalesHeader: Record "Sales Header")
    begin
        // Profiling shows Orders are the common case, so that branch goes first.
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                RouteOrder(SalesHeader);
            SalesHeader."Document Type"::Invoice:
                RouteInvoice(SalesHeader);
            SalesHeader."Document Type"::"Credit Memo":
                RouteCreditMemo(SalesHeader);
            SalesHeader."Document Type"::Quote:
                RouteQuote(SalesHeader);
            SalesHeader."Document Type"::"Return Order":
                RouteReturnOrder(SalesHeader);
        end;
    end;

    local procedure RouteOrder(SalesHeader: Record "Sales Header") begin end;
    local procedure RouteInvoice(SalesHeader: Record "Sales Header") begin end;
    local procedure RouteQuote(SalesHeader: Record "Sales Header") begin end;
    local procedure RouteCreditMemo(SalesHeader: Record "Sales Header") begin end;
    local procedure RouteReturnOrder(SalesHeader: Record "Sales Header") begin end;
}
