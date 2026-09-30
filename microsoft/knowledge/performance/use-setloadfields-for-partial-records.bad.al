codeunit 50219 "Perf Sample LoadFields Bad"
{
    procedure CollectUSCustomerNamesAndCities(var DisplayNames: List of [Text])
    var
        Customer: Record Customer;
    begin
        Customer.SetRange("Country/Region Code", 'US');
        if Customer.FindSet() then
            repeat
                DisplayNames.Add(CustomerDisplayText(Customer));
            until Customer.Next() = 0;
    end;

    local procedure CustomerDisplayText(Customer: Record Customer): Text
    begin
        exit(Customer.Name + ' ' + Customer.City);
    end;
}
