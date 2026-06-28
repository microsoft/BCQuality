// Demonstration-only AL. Not compiled by CI; illustrates the article.
codeunit 50275 "Param Naming Good Sample"
{
    procedure RegisterPayment(var SalesHeader: Record "Sales Header"; DocumentNo: Code[20]; Amount: Decimal)
    begin
        // Full, spelled-out names make the event contract self-explanatory.
        OnAfterRegisterPayment(SalesHeader, DocumentNo, Amount);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterPayment(var SalesHeader: Record "Sales Header"; DocumentNo: Code[20]; Amount: Decimal)
    begin
    end;
}
