codeunit 50111 "Job Queue Failure Good"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Customer: Record Customer;
    begin
        Customer.Get(Rec."Parameter String");
        ProcessCustomer(Customer);
    end;

    local procedure ProcessCustomer(Customer: Record Customer)
    begin
    end;
}