codeunit 50100 "Pass Var Enumerator Bad"
{
    procedure ListUsCustomerCities()
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields(Name);
        Customer.SetRange("Country/Region Code", 'US');
        if Customer.FindSet() then
            repeat
                // By-value copy: JIT on City does not update the enumerator.
                Message(Customer.Name + ' ' + CityOf(Customer));
            until Customer.Next() = 0;
    end;

    local procedure CityOf(Customer: Record Customer): Text
    begin
        exit(Customer.City);
    end;
}
