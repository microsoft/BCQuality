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
    begin
        GetCustomerName('10000', 'placeholder'); // compile error: literal is not addressable
    end;
}
