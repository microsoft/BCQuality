// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50250 "Param Append Good Sample"
{
    procedure PostDocument(var SalesHeader: Record "Sales Header"; CalledFromBatch: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // The new 'CalledFromBatch' parameter was appended at the end of the
        // existing signature, so existing subscribers needed no re-mapping.
        OnBeforePostDocument(SalesHeader, IsHandled, CalledFromBatch);
        if IsHandled then
            exit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostDocument(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean; CalledFromBatch: Boolean)
    begin
    end;
}
