// Demonstration-only AL. Version 1 exposed PostDocument(SalesHeader).
codeunit 50251 "Param Append Bad Sample"
{
    procedure PostDocument(var SalesHeader: Record "Sales Header")
    begin
        // Existing callers cannot supply the newly required argument.
        OnBeforePostDocument(SalesHeader);
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePostDocument(var SalesHeader: Record "Sales Header"; CalledFromBatch: Boolean)
    begin
    end;
}
