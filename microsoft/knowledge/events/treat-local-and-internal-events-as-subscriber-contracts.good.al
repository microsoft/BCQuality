// Demonstration-only AL. Version 1 had CustomerNo and var Score parameters.
codeunit 50520 "Customer Scoring Events"
{
    procedure ScoreCustomer(CustomerNo: Code[20]; Reason: Text; var Score: Integer)
    begin
        OnCustomerScored(CustomerNo, Reason, Score);
    end;

    // Adding Reason between existing parameters preserves subscriber bindings.
    [IntegrationEvent(false, false)]
    local procedure OnCustomerScored(CustomerNo: Code[20]; Reason: Text; var Score: Integer)
    begin
    end;
}

codeunit 50522 "Existing Scoring Subscriber"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Customer Scoring Events", 'OnCustomerScored', '', false, false)]
    local procedure OnCustomerScored(CustomerNo: Code[20]; var Score: Integer)
    begin
        if CustomerNo = '' then
            Score := 0;
    end;
}
