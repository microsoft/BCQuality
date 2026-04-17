codeunit 50134 "Perf Sample RecordRef Good"
{
    procedure BlockCustomer(CustomerNo: Code[20])
    var
        Customer: Record Customer;
    begin
        if not Customer.Get(CustomerNo) then
            exit;
        Customer.Blocked := Customer.Blocked::All;
        Customer.Modify(true);
    end;
}
