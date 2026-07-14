// Demonstration-only AL. Version 2 keeps the shipped local event unchanged.
codeunit 50520 "Customer Scoring Events"
{
    procedure ScoreCustomer(CustomerNo: Code[20]; Score: Integer; Reason: Text)
    begin
        OnCustomerScored(CustomerNo, Score);
        OnCustomerScoredV2(CustomerNo, Score, Reason);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCustomerScored(CustomerNo: Code[20]; Score: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCustomerScoredV2(CustomerNo: Code[20]; Score: Integer; Reason: Text)
    begin
    end;
}
