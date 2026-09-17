codeunit 50100 "Query Bypass PK Cache Good"
{
    procedure CustomerName(CustomerNo: Code[20]): Text
    var
        Customer: Record Customer;
    begin
        // Repeated Get of the same No. is served from the transaction PK cache.
        Customer.SetLoadFields(Name);
        if Customer.Get(CustomerNo) then
            exit(Customer.Name);
    end;
}
