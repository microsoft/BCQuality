codeunit 50131 "Perf Sample GetVsFind Bad"
{
    procedure CustomerName(CustomerNo: Code[20]): Text[100]
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("No.", CustomerNo);
        if Customer.FindFirst() then
            exit(Customer.Name);
    end;
}
