codeunit 50493 "Perf Record Clone Bad"
{
    procedure IncreaseCustomerCreditLimits(Percent: Decimal)
    var
        Customer: Record Customer;
        CustomerCopy: Record Customer;
    begin
        Customer.SetFilter("Credit Limit (LCY)", '>0');
        Customer.SetLoadFields("Credit Limit (LCY)");
        if Customer.FindSet(true) then
            repeat
                CustomerCopy.Copy(Customer);
                CustomerCopy.Validate(
                    "Credit Limit (LCY)",
                    Round(CustomerCopy."Credit Limit (LCY)" * (1 + Percent / 100)));
                CustomerCopy.Modify(true);
            until Customer.Next() = 0;
    end;
}
