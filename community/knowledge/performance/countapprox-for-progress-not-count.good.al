codeunit 50100 "CountApprox Progress Good"
{
    procedure RecalcUsCustomers()
    var
        Customer: Record Customer;
        Window: Dialog;
        Counter: Integer;
        Total: Integer;
    begin
        Customer.SetRange("Country/Region Code", 'US');
        Total := Customer.CountApprox();
        Window.Open('Processing #1###### of #2######');
        if Customer.FindSet() then
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                Window.Update(2, Total);
            until Customer.Next() = 0;
        Window.Close();
    end;
}
