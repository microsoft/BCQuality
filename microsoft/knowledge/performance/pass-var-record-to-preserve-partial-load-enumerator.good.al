codeunit 50100 "Pass Var Enumerator Good"
{
    procedure ListUsCustomerCities()
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields(Name);
        Customer.SetRange("Country/Region Code", 'US');
        if Customer.FindSet() then
            repeat
                EnsureCityLoaded(Customer);
                Message(Customer.Name + ' ' + Customer.City);
            until Customer.Next() = 0;
    end;

    local procedure EnsureCityLoaded(var Customer: Record Customer)
    begin
        if not Customer.AreFieldsLoaded(Customer.City) then
            Customer.LoadFields(Customer.City);
    end;
}
