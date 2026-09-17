// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50260 "Reuse Event Good Sample"
{
    procedure ProcessOrder(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // A single event, extended with CustomerNo appended at the end, covers
        // the need; no second event is raised beside it.
        OnBeforeProcessOrder(SalesHeader, IsHandled, CustomerNo);
        if IsHandled then
            exit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeProcessOrder(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; CustomerNo: Code[20])
    begin
    end;
}
