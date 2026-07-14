codeunit 50232 "Perf Sample ReadIso Good"
{
    procedure IsCustomerBlocked(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Customer.Get(CustomerNo) then
            exit(false);

        exit(Customer.Blocked <> Customer.Blocked::" ");
    end;
}
