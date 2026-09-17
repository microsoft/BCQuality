codeunit 50233 "Perf Sample ReadIso Bad"
{
    procedure IsCustomerBlocked(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.LockTable();
        if not Customer.Get(CustomerNo) then
            exit(false);

        exit(Customer.Blocked <> Customer.Blocked::" ");
    end;
}
