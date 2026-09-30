codeunit 50218 "Perf Sample LoadFields Good"
{
    procedure CollectUSCustomerNamesAndCities(var DisplayNames: List of [Text])
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("Country/Region Code", 'US');
        Customer.SetLoadFields(Name, City);
        if Customer.FindSet() then
            repeat
                DisplayNames.Add(CustomerDisplayText(Customer));
            until Customer.Next() = 0;
    end;

    local procedure CustomerDisplayText(Customer: Record Customer): Text
    begin
        exit(Customer.Name + ' ' + Customer.City);
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
