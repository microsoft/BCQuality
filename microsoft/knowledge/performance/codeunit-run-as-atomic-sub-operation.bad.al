codeunit 50144 "Perf Sample AtomicSub Bad"
{
    procedure ApplyDiscountToSelection(var Customer: Record Customer)
    begin
        if Customer.FindSet(true) then
            repeat
                Customer."Customer Price Group" := 'VIP';
                Customer.Modify(true);
                Commit();
            until Customer.Next() = 0;
    end;
}
