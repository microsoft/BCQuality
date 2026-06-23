// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50261 "Reuse Event Bad Sample"
{
    procedure ProcessOrder(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // Anti-pattern: a near-duplicate event raised right next to the original,
        // differing only by an extra parameter — two consecutive events where a
        // single extended event would do.
        OnBeforeProcessOrder(SalesHeader, IsHandled);
        OnBeforeProcessOrderWithCustomer(SalesHeader, CustomerNo, IsHandled);
        if IsHandled then
            exit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessOrder(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessOrderWithCustomer(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}
