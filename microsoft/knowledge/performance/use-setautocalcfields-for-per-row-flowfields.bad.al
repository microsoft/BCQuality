codeunit 50491 "Perf AutoCalcFields Bad"
{
    procedure CollectOverLimitCustomers(var CustomerNos: List of [Code[20]])
    var
        Customer: Record Customer;
    begin
        Customer.SetFilter("Credit Limit (LCY)", '>0');
        Customer.SetLoadFields("Credit Limit (LCY)");
        if Customer.FindSet() then
            repeat
                Customer.CalcFields("Balance (LCY)");
                if Customer."Balance (LCY)" > Customer."Credit Limit (LCY)" then
                    CustomerNos.Add(Customer."No.");
            until Customer.Next() = 0;
    end;
}
