// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50250 "Param Append Good Sample"
{
    procedure PostDocument(var SalesHeader: Record "Sales Header"; CalledFromBatch: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // This local event can gain an optional trailing subscriber parameter.
        OnBeforePostDocument(SalesHeader, IsHandled, CalledFromBatch);
        if IsHandled then
            exit;
    end;

    // Public events cannot use this evolution: dependent apps may raise them.
    [IntegrationEvent(false, false)]
    local procedure OnBeforePostDocument(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; CalledFromBatch: Boolean)
    begin
    end;
}
