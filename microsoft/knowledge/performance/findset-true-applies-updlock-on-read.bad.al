codeunit 50237 "Perf Sample FindSetTrue Bad"
{
    procedure ReadOnlyOverlocked() TotalNameLength: Integer
    var
        Customer: Record Customer;
    begin
        Customer.SetLoadFields(Name);
        if Customer.FindSet(true) then
            repeat
                TotalNameLength += StrLen(Customer.Name);
            until Customer.Next() = 0;
    end;
}
