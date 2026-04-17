codeunit 50130 "Perf Sample GetVsFind Good"
{
    procedure CustomerName(CustomerNo: Code[20]): Text[100]
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then
            exit(Customer.Name);
    end;
}
