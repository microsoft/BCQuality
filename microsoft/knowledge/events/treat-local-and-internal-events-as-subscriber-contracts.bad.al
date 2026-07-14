// Demonstration-only AL. Version 1 exposed Score as an Integer named Score.
codeunit 50521 "Customer Scoring Events Bad"
{
    procedure ScoreCustomer(CustomerNo: Code[20]; ScoreText: Text)
    begin
        OnCustomerScored(CustomerNo, ScoreText);
    end;

    // 'local' limits raising, not subscription. This type/name change breaks
    // subscribers compiled against the shipped event.
    [IntegrationEvent(false, false)]
    local procedure OnCustomerScored(CustomerNo: Code[20]; ScoreText: Text)
    begin
    end;
}
