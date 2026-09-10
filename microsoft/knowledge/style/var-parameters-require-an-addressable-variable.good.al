codeunit 50100 "Customer Lookup"
{
    procedure GetCustomerName(CustomerNo: Code[20]; var Name: Text[100])
    var
        Customer: Record Customer;
    begin
        if Customer.Get(CustomerNo) then
            Name := Customer.Name;
    end;

    procedure Sample()
    var
        CustName: Text[100];
    begin
        GetCustomerName('10000', CustName);
    end;
}
