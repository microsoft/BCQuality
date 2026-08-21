codeunit 50100 "CountApprox Progress Bad"
{
    procedure RecalcUsCustomers()
    var
        Customer: Record Customer;
        Window: Dialog;
        Counter: Integer;
        Total: Integer;
    begin
        Customer.SetRange("Country/Region Code", 'US');
        // Exact Count() is a SELECT COUNT(*) just to drive a progress bar.
        Total := Customer.Count();
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
