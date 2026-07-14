codeunit 50490 "Perf AutoCalcFields Good"
{
    procedure CollectOverLimitCustomers(var CustomerNos: List of [Code[20]])
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields("Credit Limit (LCY)");
        Customer.SetFilter("Credit Limit (LCY)", '>0');
        Customer.SetAutoCalcFields("Balance (LCY)");
        if Customer.FindSet() then
            repeat
                if Customer."Balance (LCY)" > Customer."Credit Limit (LCY)" then
                    CustomerNos.Add(Customer."No.");
            until Customer.Next() = 0;
    end;
}
