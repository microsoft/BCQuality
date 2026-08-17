codeunit 50218 "Perf Sample LoadFields Good"
{
    procedure ListUSCustomerNames()
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("Country/Region Code", 'US');
        Customer.SetLoadFields(Name);
        if Customer.FindSet() then
            repeat
                Message(Customer.Name);
            until Customer.Next() = 0;
    end;

    procedure LookupSkuPolicy(LocationCode: Code[10]) Policy: Enum "SKU Creation Method"
    var
        Location: Record Location;
    begin
        Location.SetLoadFields("SKU Creation Policy");
        if Location.Get(LocationCode) then
            Policy := Location."SKU Creation Policy";
    end;
}
