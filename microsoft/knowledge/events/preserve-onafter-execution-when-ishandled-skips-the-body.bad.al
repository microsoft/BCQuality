// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50246 "OnAfter Preserve Bad Sample"
{
    procedure ReleaseDocument(var SalesHeader: Record "Sales Header")
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeReleaseDocument(SalesHeader, IsHandled);

        // Bug: returning here also skips OnAfterReleaseDocument below, so
        // subscribers that rely on the after-event stop running whenever
        // another extension handles the OnBefore.
        if IsHandled then
            exit;

        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify(true);

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
