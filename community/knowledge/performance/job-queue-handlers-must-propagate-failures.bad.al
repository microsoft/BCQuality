codeunit 50111 "Job Queue Failure Bad"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        if not TryProcessCustomer(Rec."Parameter String") then
            exit;
    end;

    [TryFunction]
    local procedure TryProcessCustomer(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(CustomerNo);
        ProcessCustomer(Customer);
    end;

    local procedure ProcessCustomer(Customer: Record Customer)
    begin
    end;
}