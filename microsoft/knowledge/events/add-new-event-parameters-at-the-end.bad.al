// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50251 "Param Append Bad Sample"
{
    procedure PostDocument(var SalesHeader: Record "Sales Header"; CalledFromBatch: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // Anti-pattern: 'CalledFromBatch' was inserted before the existing
        // IsHandled parameter, shifting it and breaking the argument positions
        // every existing subscriber relied on.
        OnBeforePostDocument(SalesHeader, CalledFromBatch, IsHandled);
        if IsHandled then
            exit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostDocument(var SalesHeader: Record "Sales Header"; CalledFromBatch: Boolean; var IsHandled: Boolean)
    begin
    end;
}
