// Demonstration-only AL. Version 1 exposed var Score as an Integer.
codeunit 50521 "Customer Scoring Events Bad"
{
    procedure ScoreCustomer(CustomerNo: Code[20]; ScoreText: Text)
    begin
        OnCustomerScored(CustomerNo, ScoreText);
    end;

    // 'local' limits raising, not subscription. Renaming Score to ScoreText,
    // changing its type, and removing var all break existing subscribers.
    [IntegrationEvent(false, false)]
    local procedure OnCustomerScored(CustomerNo: Code[20]; ScoreText: Text)
    begin
    end;
}
