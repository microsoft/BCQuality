// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50245 "OnAfter Preserve Good Sample"
{
    procedure ReleaseDocument(var SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReleaseDocument(SalesHeader, IsHandled);

        // Skip only the default body, not the routine, so OnAfter still fires.
        if not IsHandled then begin
            SalesHeader.Status := SalesHeader.Status::Released;
            SalesHeader.Modify(true);
        end;

        // Fires whether or not a subscriber handled the body above.
        OnAfterReleaseDocument(SalesHeader);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeReleaseDocument(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterReleaseDocument(var SalesHeader: Record "Sales Header")
    begin
    end;
}
