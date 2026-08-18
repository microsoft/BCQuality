codeunit 50492 "Perf Record Clone Good"
{
    procedure IncreaseCustomerCreditLimits(Percent: Decimal)
    var
        Customer: Record Customer;
    begin
        Customer.SetFilter("Credit Limit (LCY)", '>0');
        Customer.SetLoadFields("Credit Limit (LCY)");
        if Customer.FindSet(true) then
            repeat
                Customer.Validate(
                    "Credit Limit (LCY)",
                    Round(Customer."Credit Limit (LCY)" * (1 + Percent / 100)));
                Customer.Modify(true);
            until Customer.Next() = 0;
    end;
}
