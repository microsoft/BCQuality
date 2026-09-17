// Demonstration-only AL. Version 1 had SalesHeader and IsHandled parameters.
codeunit 50250 "Param Append Good Sample"
{
    procedure PostDocument(var SalesHeader: Record "Sales Header"; CalledFromBatch: Boolean)
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        // Subscribers bind by name, so the new parameter can sit between the
        // existing parameters without breaking subscribers that omit it.
        OnBeforePostDocument(SalesHeader, CalledFromBatch, IsHandled);
        if IsHandled then
            exit;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostDocument(var SalesHeader: Record "Sales Header"; CalledFromBatch: Boolean; var IsHandled: Boolean)
    begin
    end;
}

codeunit 50252 "Existing Param Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Param Append Good Sample", 'OnBeforePostDocument', '', false, false)]
    local procedure OnBeforePostDocument(var SalesHeader: Record "Sales Header"; var IsHandled: Boolean)
    begin
        IsHandled := SalesHeader."No." = '';
    end;
}
