codeunit 50901 "Privacy Sample StrSubstNo Bad"
{
    procedure FailCustomer(var Customer: Record Customer)
    var
        ErrorMsg: Text;
    begin
        // Platform receives a plain Text string. It cannot inspect fields,
        // cannot classify, cannot strip. The email and address reach telemetry.
        ErrorMsg := StrSubstNo(
            'Customer %1 (%2) at %3 has invalid data',
            Customer.Name, Customer."E-Mail", Customer.Address);
        Error(ErrorMsg);
    end;
}
